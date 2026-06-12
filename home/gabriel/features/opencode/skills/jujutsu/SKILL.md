---
name: jujutsu
description: Use when working with Jujutsu (jj) version control. Covers jj git remote, jj git push, jj bookmark, common workflows, revsets, footguns, and recovery. Use for jj CLI commands, pushing, pulling, syncing with Git remotes.
---

# Jujutsu (jj)

Jujutsu is a Git-compatible version control system. The working copy is a
revision like any other, identified by `@`. Changes are snapshotted
automatically at the start of every command.

## Mental model

- **Change / Revision**: a commit (identified by short hex like `b84294d7`).
  There are two identifiers:
  - **Change ID** (e.g. `puqltutt`): stable identity that survives rewrites
    and rebases. **Always use change IDs** for `--from`, `--into`, `-r`, etc.
  - **Commit ID** (e.g. `abc123`): content hash that changes on every rewrite.
    Using a stale hash silently targets an orphaned commit with no error.
- **Bookmark**: jj's equivalent of a Git branch. Pushes/pulls operate on
  bookmarks. Bookmarks do NOT auto-advance when you create new commits.
- **Working copy** (`@`): the current change. Whenever you run a jj command,
  jj snapshots the working copy first.
- **Empty change**: a change with no diff against its parent. `jj new` creates
  an empty change by default.
- **Immutable commits**: by default, commits reachable from remote bookmarks
  are immutable. Use `--allow-backwards` or `--ignore-immutable` to override.

## Init / clone

```bash
jj git init        # New repo with co-located .git/ + .jj/
jj git clone <url> # Clone a Git repo (colocated by default)
```

## Common revsets

### Symbols

| Symbol         | Meaning                      |
| -------------- | ---------------------------- |
| `@`            | Working copy change          |
| `@-`           | Parent of working copy       |
| `root()`       | The root commit              |
| `trunk()`      | Auto-resolved trunk bookmark |
| `<change-id>`  | Prefix match on change ID    |

### Operators

| Operator | Meaning                              |
| -------- | ------------------------------------ |
| `x-`     | Parents of x                         |
| `x+`     | Children of x                        |
| `::x`    | Ancestors of x (inclusive)           |
| `x::`    | Descendants of x (inclusive)         |
| `x..y`   | Ancestors of y, excluding ancestors of x |
| `x & y`  | Intersection                         |
| `x ~ y`  | Difference                           |
| `x | y`  | Union                                |
| `~x`     | Complement                           |
| `all:x`  | Assert x matches multiple (required for `-s` with >1 result) |

### Useful functions

| Function                  | Meaning                              |
| ------------------------- | ------------------------------------ |
| `ancestors(x)`            | All ancestors of x                   |
| `descendants(x)`          | All descendants of x                 |
| `heads(x)`                | Tips of x (not ancestors of others)  |
| `roots(x)`                | Roots of x (not descendants of others) |
| `latest(x, n)`            | Most recent n commits in x           |
| `bookmarks([pattern])`    | Local bookmark targets               |
| `remote_bookmarks()`      | Remote-tracking bookmark targets     |
| `conflicts()`             | Commits with conflicts               |
| `empty()`                 | Commits modifying no files           |
| `divergent()`             | Commits with duplicate change IDs    |
| `mine()`                  | Commits by current user              |
| `files("path")`           | Commits touching a path              |
| `description("text")`     | Commits matching a pattern           |
| `visible_heads()`         | All visible heads                    |

### Common patterns

```bash
jj log -r ::                               # Everything visible (root()..visible_heads())
jj log -r ::@                              # Ancestors of @ (full history in a linear repo)
jj log -r 'remote_bookmarks()..@'           # My unpushed commits
jj log -r 'trunk()..@'                      # All commits above trunk
jj log -r '::@ ~ ::main'                    # My commits above main
jj log -r 'conflicts()'                     # Find all conflicts
jj log -r 'mine() & bookmarks()'            # My bookmarks
jj log -r 'files("src/auth.rs")'            # Commits touching a file
jj log -r 'latest(description("fix"), 5)'   # 5 newest "fix" commits
```

## Remotes

```bash
jj git remote list                          # List remotes
jj git remote add <name> <url>              # Add a remote
jj git remote remove <name>                 # Remove a remote
jj git remote set-url <name> <url>          # Change a remote's URL
jj git remote rename <old> <new>            # Rename a remote
```

For `add`, `--fetch-tags` can be `all`, `included` (default), or `none`.

## Fetching

```bash
jj git fetch                   # Fetch from default remote (usually origin)
jj git fetch --remote upstream # Fetch from specific remote
```

## Pushing

```bash
jj git push               # Push all tracked bookmarks
jj git push --allow-new   # Allow creating a new remote bookmark
jj git push -b <bookmark> # Push a specific bookmark
jj git push --remote origin
jj git push --change @    # Push only the working copy's bookmark, creates a bookmark for it (very useful for PRs, prefer it to named branches)
```

**Default push revset**: `remote_bookmarks(remote=origin)..@`

This means: push bookmarks on `@` whose remote-tracking bookmark is behind
the local one. If there is no remote-tracking bookmark at all (i.e., it would
be a new remote bookmark), jj refuses unless `--allow-new` is passed.

If `jj git push` says "No bookmarks found in the default push revset", it
means no bookmark is tracking `@` that isn't already up to date on the
remote. Create a bookmark on the current (or parent) change first.

**Always run `jj log -r 'remote_bookmarks()..@'` before pushing** to review
what will be pushed.

**Empty `@` is harmless.** If `@` is an empty, descriptionless change sitting
on top of real commits, don't bother abandoning it. Just move the bookmark to
the last real commit (`@-`) and push. jj always keeps a working copy — the
empty one is normal and doesn't need cleanup.

## Bookmarks

```bash
jj bookmark create <name> -r <rev>          # Create bookmark at revision
jj bookmark list                            # List bookmarks
jj bookmark list --all                      # Include remote bookmarks
jj bookmark move <name> --to <rev>          # Move bookmark forward
jj bookmark move <name> --to <rev> --allow-backwards  # Move bookmark anywhere
jj bookmark set <name> -r <rev>             # Create or move bookmark (idempotent)
jj bookmark delete <name>                   # Delete a bookmark
jj bookmark track <remote>/<name>           # Track a remote bookmark
```

**Footgun**: `jj bookmark create main -r @` creates the bookmark on the
working copy. If `@` is an empty change (no content), pushing this makes no
sense. Point to `@-` instead to bookmark the parent with actual content.

**Footgun**: Moving a bookmark backwards normally requires `--allow-backwards`
because jj protects tracked bookmarks from losing commits (the old bookmark
position becomes unreachable from any bookmark).

**Footgun**: Bookmark names with hyphens are parsed as subtraction in revsets.
Quote them: `jj log -r '"my-branch"..@'` or use `bookmarks(exact:"my-branch")`.

## Creating a change

**Before `jj new`**: if `@` is already empty with no description, reuse it
with `jj describe -m "message"` instead of stacking another empty commit.

```bash
jj new                     # New empty change on top of @
jj new -m "message"        # New empty change with description
jj new main                # New change on top of main bookmark
jj new feat-a feat-b       # New merge commit with both as parents
jj describe -m "message"   # Set description on current change
jj commit                  # Snapshots working copy (usually automatic)
```

### Key mental shift from Git

Git makes you explicitly finalize a commit. jj doesn't — your working copy
**is** a commit, always. `jj new` is the closest thing to `git commit`:
it **snapshots the current @** and creates a new empty one on top.

Typical workflow for a sequence of independent changes:

```bash
jj new -m "feat: add widget"         # Start change 1
# ... edit files ...
jj new -m "fix: patch widget edge"   # Finalizes change 1, starts change 2
# ... edit files ...
jj new -m "chore: format"            # Finalizes change 2, starts change 3
```

When the user says "make a new commit" or "commit this", they mean `jj new` —
close the current change and open a fresh one. Don't overthink it.

## Viewing history / status

Prefer `--git` on `diff` for machine-readable +/- output.
Avoid raw `jj diff` (color-dependent, hard to parse).

```bash
jj log                     # Show commit history
jj log -r "main..@"        # Changes since main bookmark
jj status                  # Working copy status
# Always use --git for diff output the model needs to read:
jj diff --git               # Diff working copy vs parent
jj diff --git -r @-         # Diff against parent
jj show <rev> --git            # Show details of a revision
```

## Editing changes

```bash
jj squash                  # Squash @ into parent
jj squash -i               # Interactively choose what to move to parent
jj squash --from @ --into <change-id>   # Move changes into any commit
jj squash --from @ --into <change-id> -- file1 file2  # Specific files only
jj rebase -d <rev>         # Rebase current change onto another
jj abandon                 # Abandon (delete) the working copy change
jj edit <rev>              # Make a non-@ change the working copy
jj new --insert-after <rev>  # Insert a new change between rev and its children
jj split                   # Split current change into multiple changes
```

**Important**: When source and destination have different descriptions, pass
`-m "message"` to `jj squash` to avoid the interactive editor opening in
non-interactive shells.

## Absorb

```bash
jj absorb                  # Auto-move @ changes into the nearest mutable
                           # ancestor that touches the same files/lines
```

`jj absorb` inspects which lines were last touched by each parent commit and
automatically routes your changes to the right one. Especially powerful when
working on a merge commit spanning multiple branches.

## Non-interactive commit splitting

When `jj split` (interactive) isn't usable:

```bash
# 1. Create empty targets on the parent of the big commit
jj new <big-change-id>- -m "feat: logical group 1"
jj new @ -m "feat: logical group 2"

# 2. Rebase the big commit onto the last empty commit
jj rebase -s <big-change-id> -d @

# 3. Distribute files (change IDs are stable, no re-log needed!)
jj squash --from <big-change-id> --into <target-1-id> -m "feat: logical group 1" -- file1 file2
jj squash --from <big-change-id> --into <target-2-id> -m "feat: logical group 2" -- file3 file4
```

## Conflict handling

Conflicts are stored **inside commits** -- not as working-tree markers that
block you. You can commit, rebase, and continue working while conflicts exist.

```bash
jj log -r 'conflicts()'    # Find all commits with conflicts
jj resolve                 # Open interactive merge tool for @ conflicts
jj resolve -r <rev>        # Resolve conflicts in a specific commit
```

## Undo and recovery

Every repository-modifying command is recorded. Anything can be undone.

```bash
jj undo                         # Undo the last operation
jj op log                       # View full operation history
jj op undo <op-id>              # Undo a specific operation
jj op restore <op-id>           # Restore repo state to a past operation
```

**`jj op restore` is the safety net.** If a rebase goes wrong, find a
known-good state in `jj op log` and restore to it.

## Simultaneous multi-branch work

jj's merge-commit model lets you work across multiple active branches in one
working copy:

```bash
# Create a merge commit over all active branches
jj new feat-a feat-b feat-c -m "merge: working copy"

# Make changes, then distribute them back
jj absorb       # Auto-redistributes changes to the right parent branch
```

To rebase all feature branches at once when trunk advances:

```bash
jj rebase -s 'all:roots(trunk()..@)' -o trunk()
```

## Divergence

Divergent changes (`??` in log) occur when multiple live commits share the
same change ID -- often from CI auto-commits landing on remote bookmarks.

```bash
jj log -r 'divergent()'    # Find divergent changes

# Resolution: keep one, abandon the other
jj bookmark set <name> -r <correct-commit-id>
jj abandon <wrong-commit-id>
```

**Prevention**: always `jj git fetch` before starting work on a pushed stack.

## Configuration

Config file: `~/.config/jj/config.toml`

```toml
[user]
name = "Your Name"
email = "you@example.com"

[ui]
editor = "vim"

[aliases]
l = ["log", "-r", "remote_bookmarks()..@"]
```

```bash
jj config list                           # List all config
jj config get user.email                 # Get a value
jj config set --user user.email "..."    # Set a value
```

## Common workflows

**Push a new repo to a fresh remote:**

```bash
jj bookmark create main -r @-
jj git remote add origin git@github.com:user/repo.git
jj git push --allow-new
```

**Push a change as a new bookmark (preferred)**:

```bash
jj git push --change <change-id>
```

**Create a feature and push:**

```bash
jj bookmark create my-feature -r @
jj git push --allow-new
```

**Sync with upstream:**

```bash
jj git fetch
jj rebase -d main          # If main was updated upstream
jj git push
```

## Conflicted bookmark resolution

When a remote already has a bookmark at a different commit (e.g. GitLab's
auto-created `main`), tracking it produces a conflicted bookmark:

```bash
jj bookmark track main@origin              # Import remote bookmark
jj bookmark list --all                      # Inspect: @git, @origin states
jj bookmark set main -r <our-commit>        # Resolve to our commit
jj git push -b main                         # Push to overwrite remote
```

## Common pitfalls

- **"My changes disappeared"** -- They didn't. `jj op log` + `jj undo`.
- **"Bookmark didn't move after commit"** -- Bookmarks must be moved
  explicitly. `jj bookmark move <name>`.
- **"Push was rejected"** -- jj push is a force-push by design.
- **"Squash opened an editor"** -- Pass `-m "message"` to avoid in scripts.
- **"No bookmarks found in push revset"** -- No bookmark tracking `@` that
  isn't already up-to-date. Create/move a bookmark on the relevant change.
- **"How do I see what I'm about to push?"** -- `jj log -r
  'remote_bookmarks()..@'`.

## Best practices

1. **Use change IDs, not commit hashes** -- change IDs survive all rewrites.
2. **Pass `-m` with squash in scripts** -- prevents editor from opening.
3. **Fetch before starting** -- `jj git fetch` before new work. CI may have
   landed commits.
4. **Never push without review** -- always `jj log -r
   'remote_bookmarks()..@'` and confirm with the user first.
5. **Squash before pushing** -- clean up intermediates into logical units.
6. **Use `jj undo` freely** -- every operation is undoable.
7. **Don't stack empty commits** -- before running `jj new`, check if the
   current working copy is already empty and has no description (`jj log -r @`
   shows `(empty)` and `(no description set)`). If so, reuse it: describe it
   with `jj describe -m "message"` and start working there instead of creating
   a fresh child.

## Filesets (basics)

Used with `jj diff`, `jj split`, `jj squash -i`, `jj file list`.

```bash
jj diff '~Cargo.lock'                         # Exclude lockfile
jj diff 'glob:"**/*.ts" ~ glob:"**/*.test.ts"' # TS, not tests
jj split 'src/auth'                            # Only auth directory
jj log -r 'files(glob:"**/*.go")'             # Commits touching Go files
```

## Migration notes (from Git)

| Git command                | jj equivalent                                 |
| -------------------------- | --------------------------------------------- |
| `git clone`                | `jj git clone <url>`                          |
| `git pull`                 | `jj git fetch && jj rebase -d <bookmark>`     |
| `git push`                 | `jj git push`                                 |
| `git push -u origin main`  | `jj bookmark create main -r @- && jj git push --allow-new` |
| `git branch`               | `jj bookmark list`                            |
| `git checkout -b foo`      | `jj bookmark create foo -r @`                 |
| `git merge`                | `jj new <a> <b>` (creates a merge change)     |
| `git rebase`               | `jj rebase -d <rev>`                          |
| `git stash`                | Not needed; work is always snapshotted        |
| `git add`                  | Not needed; all changes tracked automatically |
| `git commit -m "msg"`        | `jj new -m "next msg"` (snapshots @, starts new change). Use `jj describe -m "msg"` only to rename the current @. |
| `git commit --amend`       | `jj squash`                                   |
| `git log`                  | `jj log`                                      |
| `git status`               | `jj status`                                   |
| `git diff`                 | `jj diff`                                     |
| `git blame`                | `jj file annotate`                            |
| `git reflog`               | `jj op log`                                   |
| `git reset --hard`         | `jj abandon`                                  |
| `git cherry-pick`          | `jj duplicate -r <rev> -d @`                  |

## Environment

- Repo data lives in `.jj/` (not `.git/`).
- jj stores a co-located bare Git repo inside `.jj/` for Git interop.
- `jj git init` creates both `.jj/` and initializes the Git repo.
- When cloning: `jj git clone <url>` — note the `git` subcommand, not a
  top-level `jj clone`.
