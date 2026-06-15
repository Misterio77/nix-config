# Pluggy API (Open Finance data ingestion)

Financial data can be pulled via Pluggy (aggregator, connects through Open Finance).
The helper script at `scripts/pluggy_fetch.py` handles the full pipeline.

## One-time setup (browser)

```bash
python3 pluggy_fetch.py connect
```

Creates a connect token and opens the Pluggy Connect widget in the browser.
Log into your bank through the widget. After success the URL bar shows
`?item_id=<uuid>` — that's your pluggy item ID.

## Fetch data

```bash
python3 pluggy_fetch.py fetch <itemId>                  # all txns
python3 pluggy_fetch.py fetch <itemId> 2026-05-01 2026-05-31  # date range
```

Saves raw JSON to `/tmp/pluggy_data/` and prints a summary to stdout.
Output: `/tmp/pluggy_data/transactions_{account}.json` (one per account).

## API endpoints

| Step | Endpoint | Notes |
|------|----------|-------|
| Auth | `POST /auth` | `clientId` + `clientSecret` → apiKey (2h expiry) |
| Connect token | `POST /connect_token` | → accessToken (30 min) |
| Widget | `https://connect.pluggy.ai/widget?connect_token=<token>` | Browser-based OAuth |
| Item status | `GET /items/{id}` | Check sync status |
| Accounts | `GET /accounts?itemId={id}` | BANK + CREDIT accounts |
| Transactions | `GET /v2/transactions?accountId={id}` | Cursor-paginated, 500/page |
| Bills | `GET /bills?accountId={id}` | Credit card invoices (due dates, totals, minimums) |

## Key data shapes

**Transaction fields** (`GET /v2/transactions`):

| Field | Type | Notes |
|-------|------|-------|
| `id` | UUID | Pluggy's own ID |
| `description` | string | Truncated format (same as bank OFX memos) |
| `amount` | number | Positive = debit (expense), Negative = credit (refund/payment) for credit cards |
| `date` | ISO8601 | Posted date in UTC |
| `type` | `DEBIT` or `CREDIT` | Direction from account holder's perspective |
| `status` | `POSTED` or `PENDING` | Settled or not |
| `paymentData` | object | Payer/receiver info for PIX/TED transfers (name, document, bank) |
| `creditCardMetadata` | object | `installmentNumber`, `totalInstallments`, `totalAmount`, `payeeMCC` |
| `merchant` | object | Clean merchant name + CNPJ (Pro feature) |

**Credit card bill fields** (`GET /bills`):

| Field | Notes |
|-------|-------|
| `dueDate` | Due date |
| `totalAmount` | Total bill amount |
| `minimumPaymentAmount` | Minimum payment |
| `financeCharges` | Array of charges (IOF, interest, fees) |
| `payments` | Array of payments made |

## Transaction sign convention (credit card)

- **Positive** amounts = debits (new charges increasing what you owe)
- **Negative** amounts = credits/payments (reducing the balance)

## Limitation: categorization

Pluggy returns a `category` field on transactions (e.g. "Restaurants", "Transport")
but this requires a **Pro** subscription. On the free plan the category is `null`.
All categorization logic must happen client-side based on description + amount + merchant matching.

## Shared patterns

All reconciliation patterns in `auditing.md` also apply to Pluggy data — IOF,
installments, shared expenses, USD exchange rate drift, matching strategy, and
statement edge timing. Load that file when cross-referencing Pluggy
transactions against Firefly.
