# Troubleshooting jj — Diagnostic Protocol

When something looks wrong, **don't guess**. Investigate actual repo state first, classify the problem, then fix with exact commands. The single most important rule: `jj undo` is almost always safe to try first if you're unsure what just happened.

## Diagnostic Protocol

### 1. Gather state
```bash
jj st                                # working copy + conflicted bookmarks
jj log -r 'all()' --limit 30         # full visible graph (incl. detached)
jj op log --limit 20                 # what just happened
```

### 2. Classify

| Symptom | Likely cause | Fix |
|---|---|---|
| Files or commit gone | Operation removed it | `jj op log` → `jj op restore <op-id>` |
| Same change ID, multiple commits in log | Divergent change (e.g. concurrent rewrites) | `jj abandon` the wrong one, or `jj metaedit --update-change-id` |
| Push pushed the wrong commit | Bookmark points behind your work | `jj bookmark set <name> -r @-` then re-push |
| Bookmark shows `??` in `jj log` | Conflicted bookmark (local + remote diverged) | `jj bookmark list --all`, then `jj bookmark set <name> -r <correct>` or `jj git fetch` for remote-side |
| Files show conflict markers in `jj st` | First-class file conflict | Edit files to resolve, `jj st` to verify |
| Conflict propagated through descendants | Auto-rebase carried it forward | Resolve in the *root* conflict commit; descendants update automatically |
| "Commit is immutable" on rebase/describe | Targeted a tracked remote bookmark like `main` | Target the commit *above* it: `jj rebase -d main@origin`, not `-d main` |
| `main` behind `main@origin` after PR merged | Forgot to advance | `jj git fetch && jj bookmark set main -r main@origin` |
| "Working copy is stale" | Another workspace rewrote `@` | `jj workspace update-stale` |
| Push/fetch fails with refs out of sync | Git refs and jj state diverged | `jj git import` then `jj git export`, then retry |
| Can't see a commit you know exists | It's hidden | `jj log -r 'all()'` or `jj log -r '<change-id>/0'` |
| Wrong commit got edited | Edited the wrong revision | `jj undo` |

### 3. Explain root cause
Before running fixes, summarize what happened in plain language so the user understands. "Your bookmark `feature` is pointing at `@` (the empty new change), but the actual content is in `@-`. That's why `jj git push` reported nothing to push."

### 4. Fix with exact commands
Show the user exactly what you'll run and *why* each step matters. After mutations, re-run `jj st` and `jj log` to verify.

### 5. Always offer undo
End with: *if anything goes wrong, run `jj undo` to revert the last operation.*

## Rebase Matrix

`jj rebase` has source flags (what to move) and destination flags (where to put it).

### Source (what to rebase)
- `-r <rev>` — single revision; detaches it from its existing parent/child chain
- `-s <rev>` — revision and all of its descendants
- `-b <rev>` — revision and all of its ancestors up to (but excluding) destination

### Destination (where to put it)
- `-d <rev>` — make it a child of `<rev>` (most common)
- `-A <rev>` — insert *after* `<rev>` (between `<rev>` and its existing children)
- `-B <rev>` — insert *before* `<rev>` (between `<rev>` and its existing parents)

### Common patterns
```bash
jj rebase -d main@origin                 # rebase @ + descendants onto remote main
jj rebase -s <rev> -d main@origin        # rebase <rev> + descendants
jj rebase -r <rev> -d @                  # cherry-pick <rev> onto @
jj rebase -b <rev> -d main@origin        # rebase <rev> + ancestors
```

### Never
- `jj rebase -s main` if `main` is a tracked remote bookmark (immutable). Target `main..@` or use `main@origin` as the *destination*, not the source.

## Operation Log Forensics

```bash
jj op log
jj op log --limit 10
jj op show <op-id>                       # what changed in one op
jj op show <op-id> -p                    # with patches
jj op restore <op-id>                    # rewind whole repo
jj --at-op <op-id> log                   # view-only time travel
jj --at-op <op-id> diff                  # diff at that operation
jj --at-op <op-id> file show <path>      # file contents at that op
```

## Recovering Lost Files (Snapshot Scan)

If you accidentally edited or deleted a file *and ran a jj command afterwards*, the previous state is in a snapshot operation:

```bash
jj op log --no-graph -T 'if(self.snapshot(), self.id() ++ "\n")' \
  | while read -r op; do
      if jj --at-op="$op" file show path/to/file >/dev/null 2>&1; then
        jj --at-op="$op" file show path/to/file > path/to/file
        break
      fi
    done
```

This walks back through snapshot ops and restores from the most recent one in which the file existed. Caveat: only states captured by a snapshot survive. Edits made and undone *between* jj commands are not recoverable.

## When You're Truly Stuck

1. **`jj undo`** — always safe, always works. Try this first if confused.
2. **`jj op log`** — figure out what actually happened.
3. **`jj op restore <op-id>`** — rewind the whole repo to a known-good point.
4. **`jj git import` then `jj git export`** — re-sync git refs with jj state in colocated repos.
5. **Last resort:** in colocated repos, you can drop to git for things jj has no equivalent for. Bypass any plugin guards with `:;git ...` (the `:` is a no-op; the `;` separates it from `git`). Use sparingly; only for `git submodule`, `git lfs`, or genuine emergencies.

## Configuration

Config is layered (highest priority wins):

1. CLI flags
2. Workspace config
3. Repo config (`.jj/repo/config.toml`)
4. User config (`~/.config/jj/config.toml`)
5. Built-in defaults

```bash
jj config list                # show effective config
jj config set --user user.email "me@example.com"
jj config set --repo git.push origin
jj config edit --user         # opens an editor — DO NOT USE IN AGENT
```

For agent use, prefer `jj config set` (non-interactive) over `jj config edit`.

## Useful Advanced Commands

```bash
jj absorb                            # auto-route hunks of @ to ancestors
jj parallelize <rev1>::<rev2>        # convert sequential commits to siblings
jj fix                               # run configured formatters on changed files
jj file chmod x <file>               # mark a file executable
jj evolog -r <change-id>             # history of a change across rewrites
jj interdiff --from <r1> --to <r2>   # compare two versions of the same change
jj git import                        # pull git refs into jj
jj git export                        # push jj state into git refs
```
