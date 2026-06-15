---
name: jujutsu
description: "REQUIRED for any VCS operation in jj repositories (`.jj/` directory present). Activate on: commit, push, pull, status, diff, log, branch/bookmark, PR, merge, rebase, stash, conflict, undo, or any version-control task. In jj repos, use jj exclusively — running git commands can corrupt or confuse state."
---

# jj Guide for AI Agents

Jujutsu (jj) is a Git-compatible VCS with mutable commits, automatic snapshotting, no staging area, and first-class conflicts. This skill teaches you how to use it safely from a non-interactive agent environment.

If `.jj/` exists in the repo root, this is a jj repo. **Use `jj` commands, not `git`.** In a colocated repo (`.jj/` *and* `.git/`), git tools can read the state, but mutations should go through `jj` so the operation log stays consistent.

## Critical Rules

- **NEVER** use interactive flags (`-i`, `--interactive`). TUI prompts hang in agent environments. This applies to `jj split -i`, `jj squash -i`, `jj commit -i`, `jj resolve`, `jj diffedit`, etc.
- **ALWAYS** pass `-m "msg"` when describing/committing. Without `-m`, an editor opens and hangs.
- **VERIFY** mutations with `jj st` and `jj log` after `squash`, `abandon`, `rebase`, `restore`, `commit`. jj will silently do exactly what you asked, even if it wasn't what you meant.
- **PREFER change IDs** (letters, e.g. `nmwwolux`) over commit IDs (hex). Change IDs are stable across rewrites.
- **NEVER** rebase or describe an immutable commit (e.g. `main` if it's tracking a remote). Target the commit *above* it, or use `main@origin` as `--destination`.
- If you get stuck, `jj undo` reverses the last operation. `jj op log` shows everything; `jj op restore <op-id>` rewinds the whole repo.

## Mental Model

- **The working copy is a commit (`@`).** File edits auto-amend `@` on every `jj` command — there is no staging area, no `git add`, no stashing.
- **Commits are mutable** until pushed. You build commits by editing the working copy and refining with `squash`/`absorb`/`describe`/`restore`.
- **Change ID vs commit ID.** A change has a stable change ID (k-z letters). Each rewrite produces a new commit ID (hex) but the change ID is preserved.
- **Bookmarks ≈ git branches**, but they do **not** auto-advance when you make new commits. You move them yourself with `jj bookmark set` or `jj bookmark move`.
- **Conflicts live in commits.** Operations never fail on merge conflict; the conflict is recorded in the resulting commit and you resolve it later by editing files.
- **Operation log replaces reflog.** Every state change is an operation. `jj undo` / `jj op restore` make almost any mistake recoverable.

## Two Workflow Styles

There are two equivalent ways to make commits. Pick one and be consistent within a session.

### Style A — `jj commit` (closest to git)

```bash
# Make edits in @ (auto-tracked)
echo "..." > file.rs
jj st                       # verify tracked changes
jj commit -m "feat: ..."    # finalize @ as a real commit; new empty @ is created
```

After `jj commit`, the *content* lives in `@-` (the parent) and `@` is a new empty change. Bookmarks and pushes target `@-`.

### Style B — describe-first (recommended for refining)

```bash
jj st                       # if @ already has content, run `jj new` first
jj describe -m "feat: ..."  # set message before coding
# ... edit files; they auto-amend into @ ...
jj st                       # review
# Leave @ as-is. The next task starts with `jj new`.
```

Style B keeps the message in the same change you're editing, which is convenient for `jj squash`/`jj absorb` refinement. **Don't run `jj new` at the end** — leave that for the start of the next task.

## Common Workflows

### Inspect
```bash
jj st                # status
jj log               # graph of recent changes
jj log -r '::@ & ~::main@origin'   # just YOUR commits not in main
jj diff              # diff of @
jj show <change-id>  # description + diff for a commit
```

### Refine the current change
```bash
jj describe -m "better message"   # rewrite message only
jj squash                         # fold @ into its parent (amend equivalent)
jj squash --from <A> --into <B>   # move all of A into B
jj absorb                         # auto-route hunks of @ to ancestors that last touched those lines
jj restore path/to/file           # discard changes to a file (restore from parent)
jj restore --from <change-id> path/to/file   # take file from another commit
jj abandon <change-id>            # delete a commit; descendants reparent
```

### Split a change non-interactively
`jj split -i` is interactive — don't use it. Instead:
```bash
jj split file1.rs file2.rs           # named files become first commit; rest stays in @
jj split 'glob:tests/**'             # by fileset pattern
```

### Bookmarks (branches)
```bash
jj bookmark list
jj bookmark create my-feature -r @       # tracks the change ID; survives rewrites of that change
jj bookmark set my-feature -r @-         # move an existing bookmark (e.g. after `jj commit`)
jj bookmark delete my-feature
```

### Push and pull
```bash
jj git fetch                              # fetch all remotes
jj git push -b my-feature                 # push a specific bookmark
jj git push                               # push all tracked bookmarks (auto force-push on rewrites)

# Sync main, fast-forward
jj git fetch
jj bookmark set main -r main@origin

# Sync main and rebase your work onto it
jj git fetch
jj rebase -d main@origin                  # rebase YOUR commits (not main) onto remote main
```

### Address PR review

Rewrite (clean history):
```bash
jj edit <change-id>          # working copy becomes that commit
# ... fix ...
jj new                       # leave the commit
jj git push                  # auto force-pushes the rewritten bookmark
```

Additive (preserve review history):
```bash
jj new <bookmark>            # new commit on top of bookmark tip
# ... fix ...
jj commit -m "address review"
jj bookmark set <bookmark> -r @-
jj git push -b <bookmark>
```

### Conflicts

jj never fails on conflict. After a `rebase`/`new`/`squash`, run `jj st` — conflicted files are listed. Open them and resolve by hand: jj's markers look like Git's but with extra sections (`%%%%%%% diff from:` / `+++++++` / `>>>>>>>`). See `references/conflicts.md` for the marker format. Do **not** use `jj resolve` (interactive). After editing, `jj st` will show the conflict cleared automatically.

### Recovery
```bash
jj undo                      # reverse last operation
jj op log                    # full operation history
jj op restore <op-id>        # rewind the whole repo to that point
jj workspace update-stale    # fix "working copy is stale" errors
```

## Git → jj Quick Reference

| Task | git | jj |
|---|---|---|
| Status | `git status` | `jj st` |
| Diff | `git diff` | `jj diff` |
| Log | `git log` | `jj log` |
| Show commit | `git show <ref>` | `jj show <rev>` |
| Stage + commit | `git add . && git commit -m "msg"` | `jj commit -m "msg"` |
| Amend message | `git commit --amend -m "msg"` | `jj describe -m "msg"` |
| Amend content | `git commit --amend --no-edit` | `jj squash` |
| Push bookmark | `git push origin <branch>` | `jj git push -b <bookmark>` |
| Fetch | `git fetch` | `jj git fetch` |
| Pull (ff) | `git pull` | `jj git fetch && jj bookmark set main -r main@origin` |
| Pull (rebase) | `git pull --rebase` | `jj git fetch && jj rebase -d main@origin` |
| Switch branch | `git checkout <branch>` | `jj new <rev>` (new on top) or `jj edit <rev>` (resume) |
| Create branch | `git checkout -b <name>` | `jj new main` then `jj bookmark create <name>` |
| List branches | `git branch` | `jj bookmark list` |
| Stash | `git stash` | unnecessary — `jj new` leaves work in the parent |
| Cherry-pick | `git cherry-pick <rev>` | `jj duplicate <rev>` |
| Revert | `git revert <rev>` | `jj revert -r <rev>` |
| Rebase | `git rebase <base>` | `jj rebase -d <base>` |
| Reset --hard HEAD~1 | `git reset --hard HEAD~1` | `jj abandon <change-id>` |
| Reflog | `git reflog` | `jj op log` |
| Blame | `git blame <file>` | `jj file annotate <file>` |
| Worktree add | `git worktree add` | `jj workspace add` |
| Undo last op | (varies) | `jj undo` |

Full mapping (including grep, bisect, fileset patterns, file restoration): see `references/git-to-jj.md`.

## Revset Quick Reference

Revsets are jj's expression language for selecting commits. They're accepted by `-r`/`--revisions`/`--from`/`--to`/`--into` on most commands.

| Expression | Meaning |
|---|---|
| `@` | working copy commit |
| `@-` | parent of @ |
| `@--` | grandparent of @ |
| `<change-id>` | commit by change ID |
| `<bookmark-name>` | tip of a bookmark |
| `main@origin` | tip of main on origin (remote bookmark) |
| `trunk()` | configured trunk (usually `main@origin`) |
| `mine()` | commits authored by current user |
| `empty()` | commits with no diff |
| `conflicts()` | commits with unresolved conflicts |
| `description("substr")` | commits whose message matches |
| `files("path")` | commits modifying given path |
| `::x` | ancestors of `x` (inclusive) |
| `x::` | descendants of `x` (inclusive) |
| `x..y` | commits in `y` but not in `x` (set difference) |
| `x::y` | DAG range — commits between `x` and `y` |
| `x \| y` | union |
| `x & y` | intersection |
| `~x` | complement |
| `heads(x)` | commits in `x` with no children in `x` |
| `roots(x)` | commits in `x` with no parents in `x` |

Distinguish carefully: `x..y` is *set difference*; `x::y` is a *DAG path*. They are not interchangeable.

Full revset language reference: `references/revsets.md`.

## Common Pitfalls

1. **Bookmarks don't auto-advance.** After `jj commit`, you must `jj bookmark set <name> -r @-`. (`jj bookmark create <name> -r @` before working *also* works because it tracks the change ID, which follows the commit.)
2. **`@` after `jj commit` is empty.** Don't push `@`; the content is in `@-`.
3. **`jj new` ≠ `git commit`.** `jj new` creates a new empty change on top. `jj commit` finalizes `@` as a real commit and creates a new empty `@`.
4. **`::` vs `..`.** `::` is a DAG range (all ancestors of). `..` is set difference. They are *not* interchangeable.
5. **Empty commits are normal.** They mean "ready to work here."
6. **`Commit is immutable` error** — you targeted a tracked bookmark like `main` directly. Target the commit above it, or use `main@origin` as the destination.
7. **Stale working copy** — usually caused by another workspace rewriting the working-copy commit. Run `jj workspace update-stale`.
8. **Don't run `git checkout`/`git commit`/`git reset` in a colocated repo.** Use jj for mutations; use git only for read-only operations or things jj doesn't have (e.g. `git submodule`).

## Progressive Disclosure — When to Read More

Load these references on demand (don't preload):

**Language & commands**
- `references/git-to-jj.md` — full Git ⇄ jj command mapping including history rewriting, stashing, worktrees, fileset patterns
- `references/revsets.md` — complete revset language: operators, functions, string/date patterns, examples
- `references/glossary.md` — formal definitions (change, view, head, divergent, hidden, root commit, etc.)

**Topic deep-dives**
- `references/bookmarks.md` — bookmark tracking, remotes, conflicted bookmarks, multiple-remote workflows (fork vs integrator)
- `references/conflicts.md` — first-class conflicts, marker formats (jj / snapshot / git styles), long markers, missing-newline conflicts
- `references/operation-log.md` — `jj op log`, `--at-op`, recovering files from past snapshots (the "snapshot scan" trick)
- `references/workspaces.md` — multiple working copies, stale working copy recovery, colocated repos, ignored files

**Action playbooks** — read when starting one of these tasks
- `references/workflow-commit-push-pr.md` — exact step-by-step for: commit → push → open PR (with `gh`)
- `references/workflow-new-workspace.md` — create an isolated workspace + bookmark for parallel work
- `references/troubleshooting.md` — diagnostic protocol, problem→fix table, rebase matrix, op-log forensics. Use this whenever something has gone sideways.
