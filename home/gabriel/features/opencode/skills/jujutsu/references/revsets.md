# Revsets — jj's Expression Language for Selecting Commits

A **revset** is an expression that resolves to a set of commits. Most jj commands take revsets via `-r`, `--from`, `--to`, `-s`, `-d`, etc. Some commands (like `jj edit <rev>`) require the revset to resolve to exactly one commit.

By default, revsets only search **visible commits**. Hidden commits (abandoned, replaced) are only included if you explicitly mention them by commit ID, `name@remote`, or `at_operation()`.

## Symbols

- `@` — working-copy commit in the current workspace
- `<workspace-name>@` — working-copy commit in another workspace
- `<bookmark-name>` — tip of a local bookmark
- `<bookmark-name>@<remote>` — tip of a remote-tracking bookmark
- `<change-id>` (e.g. `nmwwolux`) — visible commit by change ID; unique prefixes work
- `<change-id>/0`, `<change-id>/1` — disambiguate divergent or hidden change IDs (offset 0 = newest)
- `<commit-id>` (hex) — by commit ID; unique prefixes work
- `"x-"` — quoted symbol literally named `x-` (defeats operator parsing)

**Symbol resolution priority:** tag → bookmark → git ref → commit/change ID. Override with `commit_id(abc)` or `change_id(abc)` in scripts.

## Operators

In binding-strength order:

| Op | Meaning |
|---|---|
| `x-` | Parents of `x` |
| `x+` | Children of `x` |
| `x::` | Descendants of `x` (inclusive) |
| `x..` | Revisions that are not ancestors of `x` |
| `::x` | Ancestors of `x` (inclusive) — shorthand for `root()::x` |
| `..x` | Ancestors of `x`, excluding `root()` |
| `x::y` | DAG path: descendants of `x` that are also ancestors of `y` |
| `x..y` | Set difference: ancestors of `y` that are not ancestors of `x` |
| `::` | All visible commits — same as `all()` |
| `..` | All visible commits except `root()` |
| `~x` | Complement |
| `x & y` | Intersection |
| `x ~ y` | `x` minus `y` |
| `x \| y` | Union |

Use parens for grouping: `(x & y) \| z`.

**`::` vs `..` are not interchangeable.** `B..D` includes `D` (and intermediate ancestors of `D` that aren't ancestors of `B`); `B::D` is the DAG path from `B` to `D`. See examples below.

### Operator examples

Given:
```
o D
|\
| o C
| |
o | B
|/
o A
|
o root()
```

- `D-` ⇒ `{C, B}`
- `B+` ⇒ `{D}`
- `B::` ⇒ `{D, B}`
- `B..` ⇒ `{D, C}` (descendants and siblings of descendants)
- `::D` ⇒ `{D, C, B, A, root()}`
- `B::D` ⇒ `{D, B}` (DAG path; excludes `C`)
- `B..D` ⇒ `{D, C}` (excludes `B`, includes `C`)

## Functions

### Graph navigation
- `parents(x, [depth])` — `x-` is `parents(x, 1)`
- `children(x, [depth])`
- `ancestors(x, [depth])` — `::x` is `ancestors(x)`
- `descendants(x, [depth])` — `x::` is `descendants(x)`
- `first_parent(x, [depth])` — for merges, only the first parent
- `first_ancestors(x, [depth])` — like `git log --first-parent`
- `reachable(srcs, domain)` — commits reachable from `srcs` within `domain`, traversing parent and child edges
- `connected(x)` — same as `x::x`
- `heads(x)` — commits in `x` with no descendants in `x`
- `roots(x)` — commits in `x` with no ancestors in `x`
- `fork_point(x)` — common ancestor of all commits in `x`

### Sets
- `all()`, `none()`
- `visible_heads()` — all visible heads
- `root()` — the virtual root commit
- `working_copies()` — `@` across all workspaces
- `merges()` — merge commits
- `empty()` — commits with no diff (also matches `root()` and trivial merges)
- `conflicts()` — commits with unresolved conflicts
- `divergent()` — commits with divergent change IDs
- `signed()` — cryptographically signed commits

### By identity
- `change_id(prefix)` — by change ID (forces change-id interpretation)
- `commit_id(prefix)` — by commit ID (forces commit-id interpretation)
- `bookmarks([pattern])` — local bookmark tips, optionally filtered
- `remote_bookmarks([bookmark_pattern], [remote=remote_pattern])` — remote bookmark tips
- `tracked_remote_bookmarks(...)`, `untracked_remote_bookmarks(...)`
- `tags([pattern])`
- `latest(x, [count])` — most recent `count` commits in `x` by committer time
- `bisect(x)` — commits roughly bisecting the input set
- `exactly(x, count)` — error if `x` is not size `count`

### Description / authorship
- `description(pat)` — message matches pattern
- `subject(pat)` — first line of message matches
- `author(pat)`, `author_name(pat)`, `author_email(pat)`, `author_date(pat)`
- `committer(pat)`, `committer_name(pat)`, `committer_email(pat)`, `committer_date(pat)`
- `mine()` — `author_email(exact-i:<your-email>)`

### File changes
- `files(fileset)` — commits modifying paths matching the fileset (e.g. `files("src")` matches anything under `src/`)
- `diff_contains(text, [files])` — commits whose diff matches `text`

### Special
- `present(x)` — `x` if it resolves, else `none()` (use to safely reference maybe-missing names)
- `coalesce(r1, r2, ...)` — first non-empty revset in the list
- `at_operation(op, x)` — evaluate `x` as of the given operation

## String Patterns

Functions that take a string pattern accept these prefixes:

- `"substring"` — substring match (current default)
- `exact:"string"` — exact equality
- `exact-i:"string"` — exact, case-insensitive
- `glob:"src/**/*.rs"` — Unix shell glob
- `glob-i:"..."` — glob, case-insensitive
- `regex:"^feat.*"` — Rust regex
- `regex-i:"..."`

> The default for plain `"string"` will change from `substring:` to `glob:` in a future release. Set `ui.revsets-use-glob-by-default = true` in `~/.config/jj/config.toml` to opt in early.

## Date Patterns

Used by `*_date()` functions:

- `before:"2026-01-01"`
- `after:"2025-06-15"`
- `"2025-12-25"` — exact day

## Common Recipes

```bash
# All commits in your current branch but not in origin/main
jj log -r 'main@origin..@'

# Commits I authored that aren't merged yet
jj log -r 'mine() & main@origin..'

# Last 10 of my commits
jj log -r 'latest(mine(), 10)'

# Commits touching a directory
jj log -r 'files("src/parser")'

# Commits whose message mentions a ticket
jj log -r 'description(glob:"*JJ-1234*")'

# All conflicted commits in the repo
jj log -r 'conflicts()'

# All empty commits except the working copy
jj log -r 'empty() ~ @'

# Find a commit by partial change ID, even if hidden
jj log -r 'change_id(nmwwo)'

# Restore the bookmark `feature` to the parent of where it currently is
jj bookmark set feature -r 'feature-'
```
