---
name: gabs-tools
description: Manage Gabs's todos (todoman), appointments (khal), contacts (khard), notes (~/Notes), and email (~/Mail)
---

## Todos (todoman)

Todos live in a vdir at `~/Calendars/personal/`. Use the `todo` CLI (todoman).

```bash
todo                           # list all todos (with IDs, priorities, categories)
todo done <id>                 # mark a todo as completed
todo new "task text"           # create a new todo (prompts for details interactively)
```

Categories observed: `@Magalu`, `@Postgrad`, `@Personal`, `@Casa`, `@GELOS`, `@Reading List`, `@Ideas`.

Priority markers: `!!!` (high), `!!` (medium), `!` (low), `[Quick Win]` (tag).

Todoman currently throws parse errors on some `.ics` files due to a known upstream bug with `RELATED-TO` param handling (`'list' object has no attribute 'params'`). The list still loads — these are cosmetic warnings.

## Appointments (khal)

Calendar stored as vdir `.ics` files under `~/Calendars/personal/Personal/`. Use `khal`.

```bash
khal list today 2d             # today + next 2 days
khal list 12/06/2026 15/06/2026  # specific date range
khal new                        # create a new event interactively
khal at                         # what's happening right now
khal edit -d "12/06/2026" "Event Title"  # interactively edit/delete an event
khal search "keyword"           # search events
```

**Deleting an event non-interactively:** khal has no `delete` subcommand. Instead, find the `.ics` file and remove it:

```bash
grep -rl "Event Title" ~/Calendars/personal/Personal/
rm /path/to/uid.ics
```

**Deleting a recurring event:** same approach — find the `.ics` containing the `RRULE` and delete it. All instances will vanish.

The underlying sync is done by vdirsyncer. (DAVx5 handles sync on Android.) The vdir is at `~/Calendars/personal/`.

**Syncing:** vdirsyncer syncs automatically via a systemd timer. To force an immediate sync:
```bash
systemctl --user start vdirsyncer
```

**Cache bust:** khal caches events in `~/.cache/khal/khal.db` and won't pick up manual `.ics` edits. Delete the cache after editing `.ics` files directly:

```bash
rm ~/.cache/khal/khal.db
```

## Notes (~/Notes)

Plain markdown files. Key locations:

| Path | Purpose |
|---|---|
| `~/Notes/TODO` | Main working todo (text-based, not todoman) |
| `~/Notes/Elisa/` | Advisor meeting notes, dated `YYYY-MM-DD.md` |
| `~/Notes/old/` | Archived/older notes |
| `~/Notes/old/very-old/` | Ancient notes, GELOS, classes, etc. |

The Elisa notes typically have `# Pre` (agenda) and `# Post` (action items) sections.

The `~/Notes/old/todo.md` file has a dated task breakdown (work, masters, GELOS, personal).

The Notes directory is a jj (Jujutsu) repo. Always run `jj new` before making any edits there — same workflow as any other jj repo. Use `jj` for all VCS operations, never `git`.

## Contacts (khard)

khard is a CardDAV address book client. Contacts are synced via vdirsyncer.

**To look up a contact, always use `khard show <name>` first.** It handles fuzzy matching and gives you everything (email, phone, notes, UID) in one shot. Only fall back to grep on `~/Contacts/Main/` for bulk operations or when khard misbehaves.

```bash
khard show <name>             # full contact details (phone, address, notes, etc.) — use this first
khard emails                  # list all contacts that have email addresses
khard list                    # list all contacts
```

### Editing contacts

`khard edit <name>` opens the contact in `$EDITOR`, but requires a TTY and may not work from within opencode. The fallback is to edit the vCard file directly:

```bash
# Find the vCard by UID (shown in khard show output under Miscellaneous > UID)
file=~/Contacts/Main/<UID>.vcf
```

Or grep for the name:

```bash
grep -rl "<name>" ~/Contacts/Main/
```

Then edit the `.vcf` file directly. `NOTE:` is the notes field.

## Email (~/Mail)

Mail lives in `~/Mail/` as a Maildir. Each account gets a subdirectory:

| Path | Account |
|---|---|
| `~/Mail/personal/` | hi@m7.rs (forwards from gabriel@gsfontes.com) |
| `~/Mail/usp/` | g.fontes@usp.br |

### Maildir layout

Standard Maildir: `Inbox/{cur,new,tmp}` plus `Archive/`, `Drafts/`, `Junk/`, `Sent/`, `Trash/`.

**Syncing:** mbsync syncs automatically via a systemd timer. To force an immediate sync:
```bash
systemctl --user start mbsync
```

All mail in `new/` has already been synced by mbsync — `new/` and `cur/` both contain read mail. Email files are named like:

```
<unix_ts>.<seq>_<host>,U=<uid>:2,<flags>
```

**Flags** (appended after `:2,`):
| Flag | Meaning |
|---|---|
| `S` | Seen (read) |
| `F` | Flagged (important/starred) |
| `R` | Replied |

Flags can combine, e.g. `,FRS` = Flagged + Replied + Seen.

**Moving files between mailboxes:** Always strip the `,U=<uid>` portion from the filename when moving a file to a different Maildir folder (e.g. Inbox to Archive). Otherwise the UID can clash with an existing file in the destination, causing mbsync to error out with "duplicate UID". mbsync will assign a fresh UID on the next sync.

```bash
# Strip UID before moving:
f="${src##*/}" && mv "$src" "$dest/${f//,U=[0-9]*:/:}"
```

### Reading email — workflow

1. **Get an overview first.** Use `grep` across `Inbox/cur/` for `^Subject:`, `^From:`, and `^Date:` to survey what's there before reading bodies.

2. **Check file size before reading.** Some emails contain huge base64-encoded attachments (especially .docx, PDFs, images). Use `read` on the directory to see file sizes (listed in the entries view), then use `limit` when reading to avoid dumping megabytes of base64. Emails with attachments often stretch to 500+ lines.

3. **Read with the Read tool, not cat.** Use `read` with `limit` — start with `limit=160` to grab headers + the beginning of the body. Expand if needed.

4. **Look for `text/plain` first.** Most emails are `multipart/alternative` with both `text/plain` and `text/html`. Read the `charset="UTF-8"` plaintext section — it contains the actual message without HTML soup. The boundary marker is like `--000000000000...`. Skip past the headers to find the `Content-Type: text/plain;` block.

5. **Decode base64 oneliners.** Some emails encode the entire body as base64 (no multipart). The `read` tool renders these as-is, but you can pipe through `base64 -d` in a pinch.

6. **Quoted-printable.** Most plaintext sections use `Content-Transfer-Encoding: quoted-printable`. The Read tool handles this natively — `=C3=A7` renders as `ç`, `=C2=A0` as NBSP, etc.

7. **Flagged emails are worth highlighting.** When summarizing, call out emails with `F` in the flags — Gabs intentionally marks these as important.

8. **Sort order.** Files sort by the Unix timestamp prefix in the filename, so `ls` order is chronological.

### Example: reading all inbox email

```bash
# Step 1: overview
grep '^Subject:' ~/Mail/personal/Inbox/cur/*
grep '^Subject:' ~/Mail/usp/Inbox/cur/*

# Step 2: check sizes, then read
read ~/Mail/personal/Inbox/cur/ <-- check file sizes
read ~/Mail/personal/Inbox/cur/<file> limit=160  <-- read one

# Step 3: expand if needed
read ~/Mail/personal/Inbox/cur/<file> offset=161 limit=200
```

### Drafts and Sent

- `~/Mail/personal/Sent/cur/`
- `~/Mail/usp/Sent/cur/`

These use the same Maildir layout. Read them the same way.
