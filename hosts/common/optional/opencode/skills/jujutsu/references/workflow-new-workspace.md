# Workflow: Start Work in an Isolated Workspace

For parallel development — e.g. multiple agents working on different features simultaneously, or running long tests in one workspace while iterating in another. Each workspace has its own `@` so they don't step on each other.

## 1. Create the workspace

Pick a feature name (or derive one from the task description). Create a workspace under `.worktrees/` in the main repo:

```bash
MAIN_REPO=$(jj root)
WORKSPACE_PATH="$MAIN_REPO/.worktrees/<feature-name>"
mkdir -p "$MAIN_REPO/.worktrees"
jj workspace add "$WORKSPACE_PATH" --name <feature-name>
```

## 2. Wire `$GIT_DIR` (colocated repos only)

`jj workspace add` does *not* create a `.git/` directory in the new workspace, so tools like `gh`, `git`, and various integrations will fail there. Add a `.envrc` that points them at the main repo:

```bash
if [[ -d "$MAIN_REPO/.git" ]]; then
  printf 'export GIT_DIR="%s/.git"\nexport GIT_WORK_TREE="%s"\n' \
    "$MAIN_REPO" "$WORKSPACE_PATH" > "$WORKSPACE_PATH/.envrc"
  direnv allow "$WORKSPACE_PATH" 2>/dev/null \
    || echo "Run 'source .envrc' in $WORKSPACE_PATH for gh CLI support."
fi
```

If `direnv` isn't installed, the user will need to `source .envrc` manually whenever they enter the workspace.

## 3. Enter the workspace

```bash
cd "$WORKSPACE_PATH"
source .envrc       # if direnv is not auto-loading
```

## 4. Create a bookmark for the work

Branch from `main` (or wherever the user wants) and create the bookmark *before* writing code, so the bookmark tracks the change ID:

```bash
jj new main -m "feat: <description>"
jj bookmark create <feature-name> -r @
```

Confirm to the user:

> Working on bookmark **<feature-name>** (change **<change-id>**) in workspace **<workspace-path>**. File edits auto-amend into this change. When done, run the commit/push/PR workflow to ship.

## 5. Work

Edit files freely. They are automatically amended into `@` whenever a jj command runs. Use the workflows in this skill (refine with `jj squash`/`jj absorb`/`jj describe`) the same way you would in the main workspace.

## 6. When done — clean up

After shipping (see `references/workflow-commit-push-pr.md`):

```bash
cd "$MAIN_REPO"
jj workspace forget <feature-name>
rm -rf "$WORKSPACE_PATH"
```

`jj workspace forget` removes the workspace from the repo's records but does **not** delete the directory. You delete it separately. **Never run `jj workspace forget` with no arguments** — that would forget the *default* workspace.

## Troubleshooting

- **`gh` says "not a git repository"** — `.envrc` isn't loaded. Run `direnv allow` and `cd` back in, or `source .envrc` manually.
- **"Working copy is stale"** — another workspace rewrote the working-copy commit. Run `jj workspace update-stale` in the affected workspace.
- **Cannot `cd` into the workspace** — verify `jj workspace list` shows it; if not, the `jj workspace add` failed.

## Multi-Agent Discipline

If multiple agents are sharing a repo:

- **One bookmark per agent.** Don't share bookmarks across agents.
- **One workspace per agent.** Filesystem isolation prevents agents from clobbering each other's working copies.
- **Branch from `main`, not from another agent's bookmark**, unless you really mean to build on top.
- **Push only your own bookmark.** Use `jj git push -b <my-bookmark>`, not `jj git push --all`.
