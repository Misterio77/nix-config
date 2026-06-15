#!/usr/bin/env python3

"""Firefly III API client — zero-dependency, urllib-only.

Reusable module wrapping every endpoint documented in the firefly skill.
All methods that read return parsed JSON dicts. Write methods accept plain
dicts matching the Firefly III API shape and return the response.

Usage:
    from firefly_client import FireflyClient
    ff = FireflyClient()
    txns = ff.transactions(limit=5)
    print(txns)
"""

import json
import os
import urllib.parse
import urllib.request
import urllib.error

BASE_URL = os.environ.get("FIREFLY_BASE", "https://firefly.m7.rs")
TOKEN_PATH = os.environ.get("FIREFLY_TOKEN_PATH", "/run/secrets/firefly-pat")


class FireflyError(Exception):
    """Wraps HTTP errors with status code and response body."""

    def __init__(self, status: int, body: str):
        self.status = status
        self.body = body
        super().__init__(f"HTTP {status}: {body[:200]}")


class FireflyClient:
    """Thin wrapper around the Firefly III REST API."""

    def __init__(self, base: str = BASE_URL, token_path: str = TOKEN_PATH):
        self.base = base.rstrip("/")
        try:
            with open(token_path) as f:
                self.token = f.read().strip()
        except FileNotFoundError:
            raise FireflyError(0, f"Token not found at {token_path}")

    # ── low-level request helpers ────────────────────────────────────────

    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self.token}",
            "Accept": "application/json",
            "Content-Type": "application/json",
        }

    def _request(self, method: str, path: str, body: dict | None = None
                 ) -> dict:
        url = f"{self.base}/api/v1/{path.lstrip('/')}"
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(url, data=data, method=method,
                                     headers=self._headers())
        try:
            with urllib.request.urlopen(req) as resp:
                body = resp.read().decode()
                return json.loads(body) if body else {}
        except urllib.error.HTTPError as e:
            body = e.read().decode()
            raise FireflyError(e.code, body)

    def _get(self, path: str) -> dict:
        return self._request("GET", path)

    def _get_all(self, path: str) -> list[dict]:
        """GET a paginated endpoint, returning every item across all pages."""
        url = f"{self.base}/api/v1/{path.lstrip('/')}"
        items: list[dict] = []
        page = 1
        while True:
            sep = "&" if "?" in url else "?"
            req = urllib.request.Request(f"{url}{sep}page={page}",
                                         headers=self._headers())
            with urllib.request.urlopen(req) as resp:
                body = json.loads(resp.read().decode())
            items.extend(body["data"])
            total = body.get("meta", {}).get("pagination",
                                             {}).get("total_pages", 1)
            if page >= total:
                break
            page += 1
        return items

    def _post(self, path: str, data: dict) -> dict:
        return self._request("POST", path, body=data)

    def _put(self, path: str, data: dict) -> dict:
        return self._request("PUT", path, body=data)

    def _delete(self, path: str) -> dict:
        return self._request("DELETE", path)

    # ── GET / read endpoints ─────────────────────────────────────────────

    def summary(self, start: str = "", end: str = "") -> dict:
        """GET /api/v1/summary/basic with optional date range."""
        path = "summary/basic"
        if start and end:
            path += f"?start={start}&end={end}"
        return self._get(path)

    def summary_all(self, start: str = "", end: str = "") -> dict:
        """GET /api/v1/summary with optional date range."""
        path = "summary"
        if start and end:
            path += f"?start={start}&end={end}"
        return self._get(path)

    def transactions(self, limit: int = 50, page: int = 1,
                     account_id: int | None = None,
                     start: str | None = None,
                     end: str | None = None) -> dict:
        """GET /api/v1/transactions with optional filters."""
        parts = [f"limit={limit}", f"page={page}"]
        if account_id is not None:
            parts.append(f"account_id={account_id}")
        if start is not None:
            parts.append(f"start={start}")
        if end is not None:
            parts.append(f"end={end}")
        return self._get(f"transactions?{'&'.join(parts)}")

    def search(self, query: str, limit: int = 50) -> dict:
        """GET /api/v1/search/transactions?query=..."""
        return self._get(f"search/transactions?query={urllib.parse.quote(query)}&limit={limit}")

    def categories(self) -> list[dict]:
        """GET /api/v1/categories (paginated)"""
        return self._get_all("categories")

    def budgets(self) -> list[dict]:
        """GET /api/v1/budgets (paginated)"""
        return self._get_all("budgets")

    def budget_limits(self, start: str, end: str) -> list[dict]:
        """GET /api/v1/budget-limits?start=...&end=... (paginated)"""
        return self._get_all(f"budget-limits?start={start}&end={end}")

    def budget_limits_by_id(self, budget_id: int, start: str,
                            end: str) -> list[dict]:
        """GET /api/v1/budgets/{id}/limits?start=...&end=..."""
        return self._get_all(
            f"budgets/{budget_id}/limits?start={start}&end={end}")

    def subscriptions(self) -> list[dict]:
        """GET /api/v1/subscriptions (paginated)"""
        return self._get_all("subscriptions")

    def transaction(self, group_id: int) -> dict:
        """GET /api/v1/transactions/{group_id} — full group with all splits."""
        return self._get(f"transactions/{group_id}")

    # ── POST / PUT / DELETE — all transactions are groups ────────────────

    def create_transaction(self, splits: list[dict],
                           group_title: str | None = None) -> dict:
        """POST /api/v1/transactions — create a transaction group.

        ``splits`` is a list of split dicts, one per transaction in the group.
        A "single" transaction is just a group with one entry.
        ``group_title`` is required when len(splits) > 1.

        Split shape:
            {"type": "withdrawal", "date": "2026-06-12", "amount": "42.50",
             "description": "Something", "source_id": SOURCE_ACCOUNT_ID,
             "destination_name": "Some expense", "category_name": "Some category"}
        """
        body: dict[str, object] = {"transactions": splits}
        if group_title is not None:
            body["group_title"] = group_title
        return self._post("transactions", body)

    def update_transaction(self, group_id: int,
                           transactions: list[dict],
                           group_title: str | None = None) -> dict:
        """PUT /api/v1/transactions/{group_id} — update ALL splits in a group.

        GET the group first, modify the ``transactions[]`` array, then PUT it
        back. Sending only some splits **removes** the others.
        ``group_title`` is required when the result has multiple splits.
        """
        body: dict[str, object] = {"transactions": transactions}
        if group_title is not None:
            body["group_title"] = group_title
        return self._put(f"transactions/{group_id}", body)

    def delete_transaction(self, group_id: int) -> dict:
        """DELETE /api/v1/transactions/{group_id} — deletes entire group."""
        return self._delete(f"transactions/{group_id}")


# ── CLI entrypoint ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    ff = FireflyClient()

    print("=== Summary Basic ===")
    s = ff.summary(start="2026-01-01", end="2026-12-31")
    for key, entry in s.items():
        if isinstance(entry, dict) and "title" in entry:
            print(f"  {entry['title']:50s} {entry.get('monetary_value', '?')}")

    print("\n=== Last 3 transactions ===")
    txns = ff.transactions(limit=3)
    for group in txns.get("data", []):
        for split in group["attributes"]["transactions"]:
            print(f"  [{split['date'][:10]}] R$ {split['amount']:>8s}  "
                  f"{split['description'][:50]}")

    print("\n=== Categories (sample) ===")
    cats = ff.categories()
    for c in cats[:10]:
        print(f"  [{c['id']:>4s}] {c['attributes']['name']}")

    print("\n=== Budgets ===")
    budgets = ff.budgets()
    for b in budgets:
        a = b["attributes"]
        auto = a.get("auto_budget_amount")
        print(f"  [{b['id']:>4s}] {a['name']}"
              + (f"  (auto: R$ {auto})" if auto else ""))

    print("\n=== Subscriptions ===")
    subs = ff.subscriptions()
    for sub in subs:
        a = sub["attributes"]
        print(f"  {a['name']:40s} R$ {a['amount_avg']:>8s}  "
              f"({a['repeat_freq']}, skip={a['skip']})")

    print("\nAll GET endpoints OK.")
