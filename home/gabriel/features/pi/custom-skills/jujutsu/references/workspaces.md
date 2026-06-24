# Working Copy and Workspaces

## The Working Copy Is a Commit

In jj, the working copy is *always* committed to a real commit (`@`). At the start of (almost) every jj command, jj snapshots the current state of files in the working copy and updates `@` to match. At the end of (almost) every command, jj updates the working copy to match `@`.

Consequences:

- **No staging area**, no `git add`, no `git stash`. Edits are part of `@` immediately.
- **Added files are tracked by default.** New files appear in `@` once you run any jj command. Files matching `.gitignore` are ignored. (`snapshot.auto-track` controls which paths are auto-tracked; default is everything not ignored.)
- **Removed files are untracked automatically.** Delete a file from disk → it disappears from `@`.
- **Manual tracking**: if `snapshot.auto-track` is non-default, use `jj file track` to explicitly track a file. `jj file untrack` to stop tracking (but first ignore it, otherwise the next snapshot will re-track).

`.gitignore` files work as in Git, both at the repo root, in subdirectories, and via `$XDG_CONFIG_HOME/git/ignore` and `$GIT_DIR/info/exclude`. There is no `.jjignore`. Files that were already tracked stay tracked even if they later match an ignore pattern — `jj file untrack` to remove them.

## Conflicts in the Working Copy

When you check out a conflicted commit, jj writes the conflicts into the working copy as **conflict markers**. When you next run a jj command, jj re-parses the markers and reconstructs the conflict state. So you can resolve a conflict simply by editing the file to remove the markers — no special "mark resolved" command. See `references/conflicts.md` for marker format.

## Workspaces — Multiple Working Copies, One Repo

A **workspace** is a working copy + an associated `.jj/` directory. A single repo can have many workspaces, each with its own `@`. This is jj's equivalent of `git worktree`.

Useful for: running long tests in one workspace while continuing to develop in another; one workspace per AI agent; isolating experimental rebases.

```bash
jj workspace add <path> --name <name>    # create a new workspace
jj workspace list
jj workspace root                        # path of the current workspace
jj workspace forget <name>               # remove from repo (delete files separately)
```

The new workspace's `.jj/` is linked to the main repo's commit and operation storage. Each workspace has its own `@` referenced as `<name>@` in revsets.

### Forgetting and re-adding

`jj workspace forget` removes the workspace from the repo's records but does **not** delete the files on disk. Delete the directory separately.

**Don't run `jj workspace forget` with no arguments** — that forgets the *default* workspace.

### Workspaces in colocated repos

`jj workspace add` creates a new workspace with its own `.jj/` but **no `.git/`**. Tools that expect `.git/` (like `gh`) will not work in the new workspace unless you wire them up.

The simplest fix is a `.envrc` (with [direnv](https://direnv.net/)) that points `$GIT_DIR` and `$GIT_WORK_TREE` at the main repo:

```bash
MAIN_REPO=$(jj root)
WORKSPACE_PATH="$MAIN_REPO/.worktrees/my-feature"
mkdir -p "$MAIN_REPO/.worktrees"
jj workspace add "$WORKSPACE_PATH" --name my-feature

if [[ -d "$MAIN_REPO/.git" ]]; then
  printf 'export GIT_DIR="%s/.git"\nexport GIT_WORK_TREE="%s"\n' \
    "$MAIN_REPO" "$WORKSPACE_PATH" > "$WORKSPACE_PATH/.envrc"
  direnv allow "$WORKSPACE_PATH" 2>/dev/null \
    || echo "Run 'source .envrc' in $WORKSPACE_PATH for gh CLI support."
fi
```

See `references/workflow-new-workspace.md` for the full step-by-step.

## Stale Working Copy

A jj command goes through three phases:

1. **Snapshot** the working copy (records an operation).
2. **Mutate** the in-memory state (records a new operation).
3. **Materialize** the new `@` to the working copy.

If step 3 doesn't happen — e.g. you `^C`'d the command, or another workspace rewrote `@` between snapshot and materialize — the working copy is **stale**: it points at an older operation than the repo's current head.

```bash
jj workspace update-stale
```

…re-syncs the working copy to the current `@`. If the operation that ran in step 3 has been *lost* (e.g. by `jj op abandon`), `update-stale` creates a recovery commit containing the working copy contents parented to the current `@`, so you don't lose anything.

A common cause: workspace A's `@` was rewritten by `jj edit` or `jj squash` in workspace B. Just run `jj workspace update-stale` in A.

## Colocated Repos

A repo where `.jj/` and `.git/` live side-by-side. Both jj and git tools can read it.

- **Use `jj` for mutations** (commit, rebase, push, etc.). This keeps the operation log consistent.
- **Use `git` for read-only operations** (`git log`, `git diff`) or for things jj has no equivalent for: `git submodule`, `git lfs`, `git bisect` (jj has automated bisect but not interactive), various integrations.
- After running git commands, the next `jj` command will detect git's changes and import them automatically. You usually don't need `jj git import` explicitly.

If something looks out of sync between the two views, `jj git import` (pull git refs into jj) and `jj git export` (push jj state into git refs) bring them back into agreement.

## Tracked vs Auto-tracked

The `snapshot.auto-track` config option (a fileset expression) controls which *new* paths are tracked automatically. Default is "everything not ignored." For example, to disable auto-tracking entirely:

```toml
# ~/.config/jj/config.toml
[snapshot]
auto-track = "none()"
```

Then you must `jj file track <path>` to start tracking a file.
