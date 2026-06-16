# Category audit workflow

When asked to audit transactions for correct categorization, work month-by-month:

## 1. Fetch transactions

**REQUIRED fields — always fetch these, every time you pull transactions for review:**
`notes`, `date` (timestamp), `tags`, `category_name`, `budget_name`, `transaction_journal_id`, group `id`, `amount`, `destination_name`, `destination_type`, `source_id`, `source_name`, `type`. Use the `/transactions` endpoint with a high `limit` and paginate through all pages. Flatten `attributes.transactions[]` to get every split individually.

Display format per transaction:
```
<date+TZ> <amount> | <description> | cat=<category_name> | bud=<budget_name> | dst=<destination_name> | tags=[<tags>] | notes=<notes>
```

Also pull Pluggy data (see `pluggy.md`) and cross-reference
against FF to catch card charges missing from FF, mismatched amounts,
or pending transactions.

## 2. Audit against the mapping

Load `private.md` for the full category × budget mapping table.
Flag two tiers of issues:

- **Definite:** category or budget clearly violates the mapping (e.g. a snack categorized as essential groceries, or a commute tagged as travel).
- **Questionable:** ambiguous descriptions, missing context, description/category mismatches where the actual nature is unclear.

Present the full list of issues as a quick-reference table, then walk through each one interactively:

## 3. Fix issues

For each flagged transaction, present the current state, the proposed fix, and ask the user to choose. Include a "leave as-is" option. After the user answers, apply the change via `PUT /api/v1/transactions/<gid>` with the matching `transaction_journal_id` in the body, then move to the next issue.

**IMPORTANT:** When updating a split transaction group, YOU MUST ALWAYS SEND ALL SPLITS. Always GET the group transaction first to make sure all splits survived. If one was accidentally removed, stop and let the operator know.

## 4. Ambiguous rides

When the ride's purpose is unclear (generic description like "Uber ?", or a destination whose category is uncertain), **check nearby transactions first** before asking the user:

- Look at same-day transactions for the same person (by tag) to infer the trip's purpose.
- If a ride to/from a location has no matching purchase at that location nearby, flag it as questionable and ask.
- If nearby transactions clarify the purpose, present that context in the prompt.
- Pay special attention to rides categorized as travel — these should only be for inter-city trips. Rides to universities, post offices, shops, etc. are not travel.
  - A ride to a carona meetup point for onward inter-city travel also inherits the travel category.

## 5. Summarize

After all issues for a month are resolved, summarize what was changed before moving to the next month.

## 6. Reconciliation patterns

### Matching strategy

Don't trust the statement memo blindly — banks often truncate merchant names.
If a memo doesn't match a destination in FF:
1. Try partial/substring matches — the truncated part is usually the most distinctive syllable.
2. A single charge may map to multiple FF splits (same merchant, same or adjacent date). Sum the splits and match the total.
3. Search the destination account name in FF, not the statement memo.

### Shared expenses (piggybacked purchases)

The card statement shows a single lump charge. FF splits it into:
- A withdrawal (your share, proper category/budget)
- A transfer (card → checking, no category, representing the other person's reimbursement)
- Both must match the statement total. When reconciling, look for the transfer alongside the withdrawal.

When your share is zero (fully reimbursed), there's no withdrawal — only the
transfer. Always list the component values in the transfer's **notes** so a
future audit can verify the transfer sum matches the statement items.

### Transfers vs expenses

Not every charge on the statement is a withdrawal. Before flagging a card
charge as missing from FF, audit all **transfers FROM the card** to any other
account — checking (friend repayments), investment accounts (business purchases),
or elsewhere. These transfers represent card charges that were repaid or
invested, with no P&L impact.

### Settlement method ≠ nature

The processor name is not the category. A supermarket delivery ordered through
a food app and paid via the card processor is still groceries. Don't let the
memo mislead you about what was actually bought — check the destination,
the items, or ask the user.

### IOF on international purchases

The bank charges IOF separately, then refunds it days later as a separate
credit ("IOF de volta de ..."). The IOF debit + IOF refund cancel out and aren't
recorded individually in Firefly.

### Marketplace lumps

A single marketplace charge on the card is often multiple items desmembrados in
Firefly. The statement posting date may differ from the purchase date by 1 day.
Don't flag as discrepancy — the individual FF items sum to the lump.

### Ride-hailing date lag

Statements show the posting date (1–3 days after the ride). FF records the actual
ride date. Match by amount first, then widen the date window.

### In-house card payments

Some banks process in-house payments (e.g. Uber, food delivery) on the *exact
same date* as the Firefly transaction — no 1-3 day lag. When matching these,
expect the date to line up exactly.

### Installments (parcelas)

Some banks split a purchase into installments — "Parcela 1/2", "Parcela 2/2"
appear as separate lines in the statement, each with its own posting date.
Parcela 1 lands in the current statement, Parcela 2 in the next. FF records
the full purchase price as a single transaction, not per-installment. When
auditing: the total of all installments should match the FF transaction.

### Installments spanning multiple items

A single card installment may map to multiple FF transactions that sum to the
total — the card sees one charge at the processor level, but FF tracks it as
separate items. When an installment doesn't match a single FF transaction,
sum the related items on the same date/merchant.

### End-of-statement edge

Transactions from the last 1-3 days of the month in FF may not appear in the
current statement — they post in the following month's statement. Check next
month's statement before flagging as missing. This is expected for rides,
restaurant charges, and any non-in-house payments.

### Start-of-statement edge (reverse)

Statement entries on the 1st (and sometimes 2nd) of the month may be late posts
from the last day(s) of the previous month — the card settled the charge 1 day
after purchase. When auditing, check the previous month's FF for matching
amounts before flagging as missing.

### Personal names as merchant names

In Brazil, food vendors often register their personal name instead of the
establishment name on the card machine. When a memo looks like a person's
name, search for food-related transactions around that value and date — it's
likely the same place.

### USD subscriptions — exchange rate drift

Small USD purchases are sometimes logged in FF at the *expected* BRL value at
the time of purchase. By the time the card settles (weeks later), the exchange
rate shifted by a few cents. When auditing, prefer the settled value
(purchase amount after IOF refund). Update FF to match.
