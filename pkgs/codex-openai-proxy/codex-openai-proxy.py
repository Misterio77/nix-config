#!/usr/bin/env python3
# Note: vibecoded (pi running claude-opus-4-8)
"""Tiny OpenAI-compatible proxy for a ChatGPT Codex subscription.

Bridges LibreChat's native Responses API custom endpoint to the ChatGPT Codex
backend at ``https://chatgpt.com/backend-api/codex/responses``. It does the
three things a plain custom-endpoint config in LibreChat cannot:

  1. Exchanges a refresh token for an access token on demand and derives the
     ChatGPT account id from the id_token, so no separate refresh cron is
     needed and nothing is persisted to disk.
  2. Injects the headers the Codex backend gates on (account id, originator,
     OpenAI-Beta, session id).
  3. Reshapes the request body into what the backend accepts (``store: false``,
     streaming, reasoning carried inline).

Endpoints: ``GET /v1/models``, ``POST /v1/responses`` (passthrough),
``GET /health``.

Config via environment:
  CODEX_REFRESH_TOKEN  OAuth refresh token (required)
  CODEX_CLIENT_ID      OAuth client id (default: the Codex CLI's)
  CODEX_HOST           listen address (default 127.0.0.1)
  CODEX_PORT           listen port (default 8788)
  CODEX_API_KEY        if set, clients must send it as a Bearer token
"""
from __future__ import annotations

import base64
import json
import os
import sys
import threading
import time
import urllib.error
import urllib.request
import uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# --- Constants ---------------------------------------------------------------

TOKEN_URL = "https://auth.openai.com/oauth/token"
CODEX_RESPONSES_URL = "https://chatgpt.com/backend-api/codex/responses"
# Refresh this many seconds before the token expires.
REFRESH_MARGIN = 300
# Models the subscription exposes through the Codex backend. The ChatGPT
# account only accepts the base ids here, not the `-codex`/`-mini`/`-pro`
# variants; probe with /v1/responses if OpenAI rotates the allowed set.
MODELS = ["gpt-5.5", "gpt-5.4", "gpt-5.4-mini"]

# OAuth client id used by the Codex CLI; the refresh endpoint only honours this.
CLIENT_ID = os.environ.get("CODEX_CLIENT_ID", "app_EMoamEEZ73f0CkXaXp7hrann")
REFRESH_TOKEN = os.environ.get("CODEX_REFRESH_TOKEN")
CLIENT_API_KEY = os.environ.get("CODEX_API_KEY")


def log(*args: object) -> None:
    print("[codex-proxy]", *args, file=sys.stderr, flush=True)


# --- Auth --------------------------------------------------------------------


def account_id_from_jwt(token: str) -> str:
    """Extract the ChatGPT account id from an id_token's claims."""
    payload = token.split(".")[1]
    payload += "=" * (-len(payload) % 4)  # restore base64 padding
    claims = json.loads(base64.urlsafe_b64decode(payload))
    return claims.get("https://api.openai.com/auth", {}).get("chatgpt_account_id", "")


class AuthManager:
    """Exchanges a refresh token for access tokens, in memory, on demand."""

    def __init__(self, refresh_token: str) -> None:
        self._refresh = refresh_token
        self._access = ""
        self._account = ""
        self._expires = 0
        self._lock = threading.Lock()

    def _do_refresh(self) -> None:
        log("refreshing access token")
        payload = json.dumps(
            {
                "client_id": CLIENT_ID,
                "grant_type": "refresh_token",
                "refresh_token": self._refresh,
                "scope": "openid profile email",
            }
        ).encode()
        req = urllib.request.Request(
            TOKEN_URL,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = json.load(resp)
        self._access = body["access_token"]
        if body.get("refresh_token"):
            self._refresh = body["refresh_token"]
        if body.get("id_token"):
            self._account = account_id_from_jwt(body["id_token"])
        self._expires = int(time.time() * 1000) + int(body["expires_in"]) * 1000

    def get(self) -> tuple[str, str]:
        """Return (access_token, account_id), refreshing if near expiry."""
        with self._lock:
            if self._expires - int(time.time() * 1000) < REFRESH_MARGIN * 1000:
                self._do_refresh()
            return self._access, self._account


if not REFRESH_TOKEN:
    sys.exit("CODEX_REFRESH_TOKEN is required")
AUTH = AuthManager(REFRESH_TOKEN)


# --- Upstream ----------------------------------------------------------------


def upstream_headers() -> dict:
    token, account = AUTH.get()
    return {
        "Authorization": f"Bearer {token}",
        "chatgpt-account-id": account,
        "OpenAI-Beta": "responses=experimental",
        "originator": "codex_cli_rs",
        "session_id": str(uuid.uuid4()),
        "Content-Type": "application/json",
        "Accept": "text/event-stream",
        "User-Agent": "codex_cli_rs/0.0.0",
    }


def shape_responses_body(body: dict) -> dict:
    """Coerce a Responses body into what the Codex backend accepts."""
    body = dict(body)
    # The backend is stateless for subscriptions: store must be false and
    # reasoning has to be carried inline rather than referenced by id.
    body["store"] = False
    body["stream"] = True
    # LibreChat sends reasoning controls as flat top-level params, but the
    # Responses API wants them nested under `reasoning`; fold them in (the
    # backend 400s on the flat `reasoning_effort`/`reasoning_summary` keys).
    reasoning = dict(body.get("reasoning") or {})
    if body.get("reasoning_effort"):
        reasoning["effort"] = body["reasoning_effort"]
    if body.get("reasoning_summary"):
        reasoning["summary"] = body["reasoning_summary"]
    # Always request a human-readable CoT summary, even when LibreChat sends no
    # effort (its "auto"): without this only the opaque encrypted_content comes
    # back and LibreChat shows no reasoning. Omitting `effort` lets the backend
    # pick the model default, so "auto" works. "auto" summary lets the model
    # pick summary granularity.
    reasoning.setdefault("summary", "auto")
    body["reasoning"] = reasoning
    include = set(body.get("include") or [])
    include.add("reasoning.encrypted_content")
    body["include"] = sorted(include)
    # Params the Codex backend rejects: the flat reasoning keys folded in
    # above, sampling knobs gpt-5 reasoning models don't take, plus `user`,
    # which LibreChat injects but the backend 400s on.
    for bad in ("reasoning_effort", "reasoning_summary", "temperature",
                "top_p", "max_tokens", "frequency_penalty",
                "presence_penalty", "user"):
        body.pop(bad, None)
    # store=false means nothing is persisted server-side, so input items can't
    # be referenced by id. On multi-turn/tool rounds LibreChat replays prior
    # reasoning items (rs_...) by id without their encrypted_content; the
    # backend 404s ("Items are not persisted... remove this item"). Drop bare
    # reasoning references -- keep any that still carry encrypted_content.
    if isinstance(body.get("input"), list):
        body["input"] = [
            item for item in body["input"]
            if not (isinstance(item, dict)
                    and item.get("type") == "reasoning"
                    and not item.get("encrypted_content"))
        ]
    return body


def open_upstream(body: dict):
    """POST a (shaped) Responses body; return the streaming HTTP response."""
    payload = json.dumps(shape_responses_body(body)).encode()
    req = urllib.request.Request(
        CODEX_RESPONSES_URL, data=payload, headers=upstream_headers(),
        method="POST",
    )
    return urllib.request.urlopen(req, timeout=600)


# --- SSE parsing -------------------------------------------------------------


def sse_events(resp):
    """Yield parsed JSON objects from an SSE stream."""
    for raw in resp:
        line = raw.decode("utf-8", "replace").strip()
        if not line.startswith("data:"):
            continue
        data = line[len("data:"):].strip()
        if not data or data == "[DONE]":
            continue
        try:
            yield json.loads(data)
        except json.JSONDecodeError:
            continue


# --- HTTP handler ------------------------------------------------------------


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, *args):  # quieter default logging
        return

    def _authorized(self) -> bool:
        if not CLIENT_API_KEY:
            return True
        auth = self.headers.get("Authorization", "")
        return auth == f"Bearer {CLIENT_API_KEY}"

    def _json(self, code: int, obj: dict) -> None:
        data = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _begin_sse(self) -> None:
        # No Content-Length and we don't chunk, so the client detects the end
        # of the stream by the connection closing -- force that.
        self.close_connection = True
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Connection", "close")
        self.end_headers()

    def _error(self, code: int, message: str) -> None:
        self._json(code, {"error": {"message": message, "type": "proxy_error"}})

    def _read_body(self) -> dict:
        length = int(self.headers.get("Content-Length", 0))
        return json.loads(self.rfile.read(length) or b"{}")

    # -- routing --
    def do_GET(self):
        if self.path == "/health":
            return self._json(200, {"status": "ok"})
        if self.path.rstrip("/") == "/v1/models":
            if not self._authorized():
                return self._error(401, "invalid api key")
            return self._json(200, {
                "object": "list",
                "data": [
                    {"id": m, "object": "model", "owned_by": "openai"}
                    for m in MODELS
                ],
            })
        return self._error(404, f"no route for GET {self.path}")

    def do_POST(self):
        if not self._authorized():
            return self._error(401, "invalid api key")
        try:
            body = self._read_body()
        except (ValueError, json.JSONDecodeError):
            return self._error(400, "invalid json body")
        route = self.path.rstrip("/")
        try:
            if route == "/v1/responses":
                return self._handle_responses(body)
        except urllib.error.HTTPError as e:
            detail = e.read().decode("utf-8", "replace")
            log(f"upstream {e.code}: {detail[:500]}")
            return self._error(e.code, f"codex backend: {detail[:500]}")
        except Exception as e:  # noqa: BLE001 - surface to client
            log("error:", repr(e))
            return self._error(502, str(e))
        return self._error(404, f"no route for POST {self.path}")

    # -- /v1/responses : passthrough (optionally de-streamed) --
    def _handle_responses(self, body: dict):
        wants_stream = body.get("stream", False)
        resp = open_upstream(body)
        if wants_stream:
            self._begin_sse()
            for raw in resp:
                self.wfile.write(raw)
            self.wfile.write(b"data: [DONE]\n\n")
            return
        # Reassemble a non-streaming response object for the caller. The Codex
        # backend leaves `output` empty on `response.completed`; the finished
        # items arrive on `response.output_item.done` events instead.
        final = None
        items: list[dict] = []
        for evt in sse_events(resp):
            t = evt.get("type")
            if t == "response.output_item.done" and evt.get("item"):
                items.append(evt["item"])
            elif t == "response.completed":
                final = evt.get("response")
        if final is None:
            return self._error(502, "no response.completed event from backend")
        if not final.get("output"):
            final["output"] = items
        return self._json(200, final)


def main() -> None:
    host = os.environ.get("CODEX_HOST", "127.0.0.1")
    port = int(os.environ.get("CODEX_PORT", "8788"))
    server = ThreadingHTTPServer((host, port), Handler)
    log(f"listening on http://{host}:{port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
