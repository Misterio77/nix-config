#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3
"""Pull bank accounts + card transactions via Pluggy.

Usage:
  1. One-time connection:
       pluggy_fetch.py connect
     Opens browser → log into your bank → copy item_id from URL bar.

  2. Fetch transactions for a month:
       pluggy_fetch.py fetch <itemId> 2026-05-01 2026-05-31
     Saves JSON to /tmp/pluggy_data/ and prints summary.

  3. Fetch everything:
       pluggy_fetch.py fetch <itemId>
"""

import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

PLUGGY_CLIENT_ID = os.environ.get("PLUGGY_CLIENT_ID", "e2c80f12-53f7-4e4b-b032-065f477a82b7")

_secret_path = os.environ.get("PLUGGY_SECRET_PATH", "/run/secrets/pluggy-secret")
PLUGGY_CLIENT_SECRET = open(_secret_path).read().strip()

API_BASE = os.environ.get("PLUGGY_API_BASE", "https://api.pluggy.ai")
OUTPUT_DIR = "/tmp/pluggy_data"


class PluggyClient:
    def __init__(self):
        self.api_key = None
        self._expires_at = 0

    def _auth(self):
        if self.api_key and time.time() < self._expires_at:
            return
        body = json.dumps({"clientId": PLUGGY_CLIENT_ID,
                           "clientSecret": PLUGGY_CLIENT_SECRET}).encode()
        req = urllib.request.Request(f"{API_BASE}/auth", data=body,
                                     headers={"Content-Type": "application/json"},
                                     method="POST")
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read())
        self.api_key = data["apiKey"]
        self._expires_at = time.time() + 7000

    def _request(self, method, path, body=None, params=None):
        self._auth()
        url = f"{API_BASE}{path}"
        if params:
            url += "?" + urllib.parse.urlencode(params, doseq=True)
        data = json.dumps(body).encode() if body else None
        req = urllib.request.Request(url, data=data, method=method,
                                     headers={"X-API-KEY": self.api_key,
                                              "Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(req) as resp:
                return json.loads(resp.read())
        except urllib.error.HTTPError as e:
            body = e.read().decode()
            raise SystemExit(f"HTTP {e.code}: {body}")

    def _get(self, path, params=None):
        return self._request("GET", path, params=params)

    def _post(self, path, body=None):
        return self._request("POST", path, body=body)

    def create_connect_token(self, client_user_id="gabs-opencode"):
        return self._post("/connect_token", {"clientUserId": client_user_id})

    def get_item(self, item_id):
        return self._get(f"/items/{item_id}")

    def list_accounts(self, item_id):
        return self._get("/accounts", {"itemId": item_id})

    def list_transactions(self, account_id, date_from=None, date_to=None):
        params = {"accountId": account_id}
        if date_from:
            params["dateFrom"] = date_from
        if date_to:
            params["dateTo"] = date_to
        all_results = []
        while True:
            data = self._get("/v2/transactions", params)
            all_results.extend(data.get("results", []))
            nxt = data.get("next")
            if not nxt:
                break
            qs = urllib.parse.parse_qs(nxt.lstrip("?"))
            params["after"] = qs["after"][0]
        return all_results

    def list_bills(self, account_id):
        return self._get("/bills", {"accountId": account_id})


def fmt_amount(amt, ttype):
    sign = "-" if ttype == "DEBIT" else "+"
    return f"{sign}R${abs(amt):>8.2f}"


def cmd_connect():
    client = PluggyClient()
    result = client.create_connect_token()
    token = result["accessToken"]
    widget_url = f"https://connect.pluggy.ai/widget?connect_token={token}"
    print("Opening browser to connect your bank...")
    print(f"  URL: {widget_url}")
    print()
    print("After logging in, look at the URL bar for: &item_id=YOUR-ITEM-ID&")
    subprocess.run(["xdg-open", widget_url], check=False)


def cmd_fetch(item_id, date_from=None, date_to=None):
    client = PluggyClient()
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    item = client.get_item(item_id)
    status = item.get("executionStatus")
    print(f"Item status: {status}")
    with open(f"{OUTPUT_DIR}/item.json", "w") as f:
        json.dump(item, f, indent=2, default=str)

    accounts = client.list_accounts(item_id).get("results", [])
    if not accounts:
        print("No accounts found.")
        return
    with open(f"{OUTPUT_DIR}/accounts.json", "w") as f:
        json.dump(accounts, f, indent=2, default=str)

    print(f"\n{'='*60}")
    print(f"Accounts ({len(accounts)})")
    print(f"{'='*60}")
    for acct in accounts:
        aid = acct["id"]
        name = acct.get("marketingName") or acct.get("name", "?")
        sub = acct["subtype"]
        bal = acct.get("balance", 0)
        print(f"\n  [{aid}] {name}")
        print(f"       Type: {acct['type']}/{sub}  Balance: R${bal:,.2f}")
        if sub == "CREDIT_CARD":
            cd = acct.get("creditData", {})
            print(f"       Limit: R${cd.get('creditLimit',0):,.2f}")
            print(f"       Due: {cd.get('balanceDueDate','?')}")

    for acct in accounts:
        aid = acct["id"]
        name = acct.get("marketingName") or acct.get("name", "?")
        safe = name.replace(" ", "_").lower()
        print(f"\n  Fetching transactions for {name} ...")

        txns = client.list_transactions(aid, date_from, date_to)
        with open(f"{OUTPUT_DIR}/transactions_{safe}.json", "w") as f:
            json.dump(txns, f, indent=2, default=str)

        posted = [t for t in txns if t.get("status") == "POSTED"]
        posted.sort(key=lambda t: t["date"], reverse=True)
        total_debit = sum(t["amount"] for t in posted if t["type"] == "DEBIT")
        total_credit = sum(abs(t["amount"]) for t in posted if t["type"] == "CREDIT")
        print(f"       {len(posted)} posted: "
              f"R${total_debit:,.2f} spent, R${total_credit:,.2f} received")
        print(f"       Last 5:")
        for t in posted[:5]:
            print(f"         [{t['date'][:10]}] {fmt_amount(t['amount'], t['type'])} "
                  f"{t.get('description','?')[:55]}")

        if acct.get("subtype") == "CREDIT_CARD":
            try:
                bills = client.list_bills(aid)
                with open(f"{OUTPUT_DIR}/bills_{safe}.json", "w") as f:
                    json.dump(bills, f, indent=2, default=str)
                br = bills.get("results", [])
                if br:
                    print(f"       Bills: {len(br)}")
                    for b in br[:3]:
                        print(f"         Due {b.get('dueDate','')[:10]}  "
                              f"R${b.get('totalAmount',0):,.2f}  "
                              f"min R${b.get('minimumPaymentAmount',0):,.2f}")
            except Exception:
                pass

    print(f"\n  Data saved to {OUTPUT_DIR}/")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__.strip())
        sys.exit(1)

    cmd = sys.argv[1]
    if cmd == "connect":
        cmd_connect()
    elif cmd == "fetch":
        if len(sys.argv) < 3:
            print("Usage: pluggy_fetch.py fetch <itemId> [dateFrom] [dateTo]")
            sys.exit(1)
        cmd_fetch(sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else None,
                  sys.argv[4] if len(sys.argv) > 4 else None)
    else:
        print(__doc__.strip())
