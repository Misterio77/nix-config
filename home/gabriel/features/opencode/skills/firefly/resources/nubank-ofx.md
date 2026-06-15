# OFX statement audit

Notes on the `.ofx` and `.pdf` files from Nubank.

## OFX file format

Nubank exports card statements as OFX (Open Financial Exchange) files.
Key characteristics:

- **Encoding:** UTF-8, XML-like structure
- **Merchant names** are truncated to ~14 characters. The raw OFX `NAME` field
  often differs from the full merchant name (e.g. `Frogpay*Farmacia Rosar`
  → Farmácia Rosário). The `Frogpay*` prefix indicates a payment processor.
- **Installments** appear as separate `STMTTRN` entries, each with its own
  `DTPOSTED` date. The `NAME` field includes the installment number
  (e.g. `Drogaria_sp Drogariasp 1/2`).
- **IOF** on international purchases: charged as a separate `STMTTRN` with
  a negative amount (credit), then refunded days later as another entry
  ("IOF de volta de ...").
- **NuPay payments** (Uber, iFood) post on the same date as the purchase —
  no 1-3 day lag like other card transactions.

## OFX memo → FF account mapping

Mnemonic table for translating Nubank's truncated/cryptic OFX memos
to Firefly expense accounts:

| OFX memo | FF account | Notes |
|---|---|---|
| `G Pagani` | Hot Tiger | Food vendor, personal name on machine |
| `Frogpay*Farmacia Rosar` | Farmácia Rosário | Truncated + acronym missing |
| `Raia\d+` | Drogaraia | "Raia" is the brand, number is the branch |
| `Drogaria_sp Drogariasp` | Drogaria São Paulo | Truncated at 14 chars |
| `Ifd\*Virele Delivery` | Mana Poke | iFood delivery; merchant name on machine |

## PDF statement format

The monthly PDF statement includes:
- Total balance, close date, and due date per card
- Per-card breakdown when multiple cards exist on the same account
- Each transaction shows: date, merchant name (untruncated), amount,
  installment info, and card last-4-digits (`•••• NNNN`)

All cards map to the same Firefly account (see `private.md` for the
physical card → owner mapping).

## Related files

Reconciliation patterns (how to match OFX data against Firefly) are in
`auditing.md`. Pluggy integration (alternative data source) is in `pluggy.md`.
