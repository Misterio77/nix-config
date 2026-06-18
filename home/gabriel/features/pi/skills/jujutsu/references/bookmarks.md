# Bookmarks (Branches), Tracking, and Remotes

A **bookmark** is a named pointer to a commit, equivalent to a Git branch but with two important differences:

1. **No "current bookmark."** Bookmarks do *not* automatically advance when you make new commits. You move them manually with `jj bookmark set` (or create them with `jj bookmark create -r @`, which tracks the change ID and follows it through rewrites).
2. **Bookmarks follow rewrites by change ID.** If you rebase or amend a commit a bookmark points to, the bookmark moves to the new commit ID automatically.

`jj` ↔ `git` mapping: in a colocated repo, each local Git branch corresponds to a `jj` bookmark of the same name, and `jj git push --bookmark foo` updates the `foo` branch on the remote.

## Basics

```bash
jj bookmark list                # local bookmarks
jj bookmark list --all          # also remote-tracking bookmarks
jj bookmark list -t             # only tracked bookmarks
jj bookmark list -t <name>      # is this bookmark tracked?

jj bookmark create my-feature -r @
jj bookmark set my-feature -r @-      # move (force, prompts on demotion)
jj bookmark move my-feature --to <change-id>
jj bookmark delete my-feature

# One-letter aliases:
#   jj b c my-feature -r@   ≡ jj bookmark create my-feature -r @
```

## `bookmark create` vs `bookmark set`

- `jj bookmark create <name> -r @` — creates a bookmark, tracking the change ID at `@`. If you later rewrite that change (e.g. via `jj commit`, `jj squash`, `jj rebase`), the bookmark follows it because the change ID is preserved across rewrites.
- `jj bookmark set <name> -r <rev>` — explicitly moves an existing bookmark to a revision. Required after creating a *fresh* commit with `jj commit` if the bookmark didn't track the change ID beforehand.

This is why the recommended pattern is **bookmark *before* you commit**:

```bash
jj new main -m "feat: ..."
jj bookmark create my-feature -r @     # tracks the change ID
# ... edit, commit, refine ...
jj git push -b my-feature              # bookmark already in the right place
```

## Remote-Tracking Bookmarks

A **remote bookmark** (`main@origin`) is a record of where a bookmark pointed on a remote the last time you fetched from it. A remote bookmark can be **tracked** by a local bookmark of the same name, in which case `jj git fetch` automatically propagates remote moves into the local bookmark (creating it if needed).

```bash
jj bookmark track main@origin              # start tracking
jj bookmark untrack main@origin            # stop tracking
jj bookmark list -t                        # list tracked bookmarks
```

### Auto-tracking

- `jj git clone` automatically tracks the default branch (e.g. `main@origin`).
- `jj git push -b <name>` automatically tracks the new remote bookmark.
- All other newly fetched remote bookmarks default to *untracked*. Track them manually with `jj bookmark track`.
- Set `remotes.<name>.auto-track-bookmarks = "*"` in config to track every newly fetched bookmark automatically (Mercurial-style).

### Tracking notation

A `*` after a bookmark name in `jj log` (e.g. `main*`) means the local bookmark differs from its tracked remote position — usually a hint that you may want to push.

## Push Safety

Before `jj git push` actually moves a remote bookmark, it:

1. **Verifies the remote bookmark is where jj expects it.** If it isn't, push refuses and tells you to `jj git fetch` first. This is similar to `git push --force-with-lease`, but more reliable: it works correctly even with concurrent background fetches.
2. **Refuses to push a conflicted local bookmark.** Resolve the conflict first.
3. **Refuses to push if the existing remote bookmark isn't tracked.** Track it first.

`jj git push` automatically force-pushes when bookmarks point at rewritten commits — that's expected, since rewrites are the normal jj workflow.

## Conflicted Bookmarks

A bookmark can be **conflicted** if it was moved both locally and remotely in a non-fast-forward way. `jj st` and `jj bookmark list` flag this; `jj log` shows the name with `??` (e.g. `main??`) on each candidate target. Using the bookmark name as a revset will then resolve to multiple commits, which causes errors like "revset resolved to multiple revisions."

To resolve:

```bash
# Local bookmark conflict — explicitly choose a target
jj bookmark set main -r <correct-commit>

# Or merge the candidates first, then move
jj new main                # creates a merge of all candidates
jj bookmark set main -r @-

# Remote bookmark conflict — just pull again
jj git fetch
```

## Multiple Remotes

Two common workflows:

### Contributing upstream via a GitHub-style fork

`upstream` is the canonical repo (read-only); `origin` is your fork (write).

```bash
jj config set --repo git.fetch '["upstream", "origin"]'   # fetch both by default
jj config set --repo git.push origin                      # push to fork by default
jj bookmark track main@upstream main@origin               # track both
jj config set --repo 'revset-aliases."trunk()"' main@upstream
```

This way, fetching pulls upstream changes into your local `main`, and `jj git push` puts feature bookmarks on your fork.

### Independent fork that periodically integrates upstream

`origin` is your repo (write); `upstream` is the original (you don't push there).

```bash
jj config set --repo git.fetch '["origin"]'    # or both, your call
jj config set --repo git.push origin
jj bookmark track main@origin
jj bookmark untrack main@upstream
jj config set --repo 'revset-aliases."trunk()"' main@origin
```

### General guidance

- Set `trunk()` to whatever remote bookmark you usually rebase onto.
- Tracking a remote bookmark means *the local and remote should move together*. Don't track if you want them to drift independently.

## Common Pitfalls

- **Forgot to advance the bookmark after `jj commit`.** Pushed the wrong commit. Fix: `jj bookmark set <name> -r @-` then `jj git push`.
- **`jj rebase -d main` failed with "commit is immutable."** `main` is a tracked remote bookmark and is immutable. Use `jj rebase -d main@origin` or target the commit above `main`.
- **`jj bookmark list` shows `feature*`** — your local bookmark moved but you haven't pushed it.
- **Pushed and then someone else force-pushed to the same bookmark.** Next push will be refused; `jj git fetch` to pull, resolve the bookmark conflict, then push again.
