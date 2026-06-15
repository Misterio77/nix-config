---
name: lumis
description: Handle MTG proxy printing side business tasks — orders, spreadsheet tracking, supply planning.
---

# Lumis — MTG Proxy Printing

Side business: prints Magic: The Gathering proxy cards for friends and local players.

See `resources/private.md` for spreadsheet URLs, tab gids, and partner names.

## Setup

Equipment and supplies pool. All revenue goes to dedicated accounts. Shipping costs reimbursed to whoever paid.

**End goal:** Earn enough for each partner to have their own setup (printer, cutter, laminator) and operate independently.

## Tracking

Orders are tracked in a Google Sheets spreadsheet with four tabs:

| Tab | Purpose |
|-----|---------|
| Geral | Summary dashboard: total spend/income split, profit, result |
| Finanças | Expenses (equipment split between partners) and client revenue |
| Pedidos | Client order pipeline with fulfillment checkboxes |
| Pedidos Free | Personal decks printed at cost — no revenue |

CSV export:
```
{SPREADSHEET_URL}/export?format=csv&gid=<gid>
```

**Important:** Always parse with a proper CSV parser. The card list columns contain embedded newlines, so line-based tools (`awk`, `rg`, `cut`) will split rows incorrectly. Use Python's `csv` module:

```bash
python3 -c "
import csv
with open('/tmp/lumis_pedidos.csv') as f:
    reader = csv.DictReader(f)
    for i, row in enumerate(reader):
        print(f'Row {i+2}: Status={row[\"Status\"]!r}  Client={row[\"Cliente\"]}  Qty={row[\"Qtd\"]}  Valor={row[\"Valor\"]}  Data={row[\"Data\"]}')
"
```

The example uses Pedidos-specific columns (Status, Cliente, Qtd, Valor, Data). Adapt for other tabs. Geral and Finanças are multi-table tabs and need different handling.

**Parsing the Lista column:** Each line in a card list is prefixed with a quantity (e.g. `15 Goblin Token (SLD) 2421` means 15 copies). If no leading number (e.g. `Goblin Recruiter (SLD) 1313`), quantity is 1. Always parse the leading number — never count lines. A line with `//` indicates a double-sided card (DFC or token with card back).

## Workflow

1. Client sends card list (usually via WhatsApp)
2. Generate PDF, check `PDF=TRUE`
3. Client confirms → check `Confirmado=TRUE`
4. Print + cut, sleeve if requested → check `Produzido=TRUE`
5. Deliver (presencial meetup or Correios shipping) → check `Enviado/Marcado=True`
6. Order arrives → check `Entregue`
7. Payment (usually na entrega: cash/Pix) → check `Pago`

**Pago must only be checked after payment is registered in the Finanças tab.**

## Status reference

| PDF | Confirmado | Meaning |
|-----|-----------|---------|
| FALSE | FALSE | PDF not generated yet. |
| TRUE | FALSE | Waiting for client confirmation. |
| TRUE | TRUE | Confirmed, moving through fulfillment. |

Orders can be blocked due to lack of materials (especially large ones).

## Materials

- **Paper:** 160g double-sided glossy A4 (Foto Glossy).
- **Laminating sheets:** 70-micron A4.
- **Ink:** Epson EcoTank refillable — a set of bottles prints ~300 single-side pages (~2700 card-sides).
- **Yield:** **1 A4 sheet + 1 laminating sheet = 9 cards.** This is the fundamental ratio for all supply calculations.
- **Process:** cards printed onto paper, then laminated, then cut. Waste always consumes both.
- **Supply tracking:** purchases logged in Finanças. Consumption tracked implicitly via produced card counts (`ceil(cards / 9)`).
- **Batching:** Multiple orders printed together on the same sheets. Sum all card quantities first, then divide by 9 and ceil once. Do NOT round per-order — that overcounts.
- **Double-sided printing:** controlled by Verso column. No extra paper/laminating consumed — only more ink. Sheet count is always `ceil(cards / 9)`.
- **Pre-tracking waste:** some sheets consumed before tracking began (personal cards, tests, errors).

## Calculating current material supply

1. **Purchases** — from Finanças, sum all 160g paper and 70-micron laminating purchases.
2. **Consumption** — from Pedidos + Pedidos Free, sum produced card quantities (`Produzido=TRUE`). `ceil(cards / 9)`.
3. **Pre-tracking waste** — add estimated waste (see `resources/private.md`).
4. **Remaining** = purchases − consumption − waste.

Compare remaining stock against pending orders. Sum all pending card quantities first, then `ceil(total / 9)`.
