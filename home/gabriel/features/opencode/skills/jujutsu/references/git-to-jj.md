# Git → jj Complete Command Reference

## Daily Operations

| Task | Git | jj | Notes |
|---|---|---|---|
| Status | `git status` | `jj st` | All changes auto-tracked; no staging |
| Diff working copy | `git diff` | `jj diff` | Diff of `@` vs its parent |
| Diff staged | `git diff --cached` | N/A | jj has no staging area |
| Diff between revs | `git diff a..b` | `jj diff --from a --to b` | |
| Log | `git log` | `jj log` | Default shows all visible heads |
| Log oneline | `git log --oneline` | `jj log -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"' --no-graph` | Custom template |
| Show commit | `git show <ref>` | `jj show <rev>` | |
| Blame | `git blame <file>` | `jj file annotate <file>` | |
| Grep | `git grep <pat>` | `jj file search <pat>` | |
| Bisect | `git bisect run <cmd>` | `jj bisect run <cmd>` | jj only supports automated bisect |

## Committing

| Task | Git | jj | Notes |
|---|---|---|---|
| Stage all + commit | `git add -A && git commit -m "msg"` | `jj commit -m "msg"` | All changes auto-tracked |
| Stage specific + commit | `git add file && git commit -m "msg"` | `jj commit -m "msg" file` | Fileset arguments |
| Amend message only | `git commit --amend -m "msg"` | `jj describe -m "msg"` | |
| Amend content | `git add . && git commit --amend` | `jj squash` | Fold `@` into `@-` |
| Amend specific files | `git add file && git commit --amend` | `jj squash file` | Partial squash |
| Empty commit | `git commit --allow-empty -m "msg"` | `jj commit -m "msg"` | Empty commits are normal in jj |

## Branching / Bookmarks

| Task | Git | jj | Notes |
|---|---|---|---|
| List branches | `git branch` | `jj bookmark list` | |
| List all (incl. remote) | `git branch -a` | `jj bookmark list --all` | |
| List tracked | `git branch -vv` | `jj bookmark list -t` | |
| Create branch | `git branch <name>` | `jj bookmark create <name> -r @` | Must specify a revision |
| Create + switch | `git checkout -b <name>` | `jj new main -m "desc"` then `jj bookmark create <name> -r @` | Two-step |
| Switch branch | `git checkout <branch>` | `jj new <branch>` (new commit on top) or `jj edit <branch>` (edit in place) | |
| Move bookmark | `git branch -f <name> <ref>` | `jj bookmark set <name> -r <rev>` | |
| Delete branch | `git branch -d <name>` | `jj bookmark delete <name>` | |
| Rename | `git branch -m old new` | `jj bookmark delete old && jj bookmark create new -r <rev>` | No rename command |
| Track remote | `git branch -u origin/main` | `jj bookmark track main@origin` | |
| Untrack remote | (varies) | `jj bookmark untrack <name>@<remote>` | |

## Remote Operations

| Task | Git | jj | Notes |
|---|---|---|---|
| Push tracked | `git push` | `jj git push` | Auto force-pushes rewritten bookmarks |
| Push specific | `git push origin <branch>` | `jj git push -b <bookmark>` | |
| Push new bookmark | `git push -u origin <branch>` | `jj git push -c <rev>` | Auto-creates bookmark from change description |
| Push all | `git push --all` | `jj git push --all` | |
| Fetch | `git fetch` | `jj git fetch` | |
| Pull (fast-forward) | `git pull` | `jj git fetch && jj bookmark set main -r main@origin` | Local advances explicitly |
| Pull (rebase local) | `git pull --rebase` | `jj git fetch && jj rebase -d main@origin` | Rebase YOUR commits, never `-s main` |
| Clone | `git clone <url>` | `jj git clone <url>` | |
| Add remote | `git remote add <name> <url>` | `jj git remote add <name> <url>` | |
| Init | `git init` | `jj git init [--no-colocate]` | Default is colocated |

## History Rewriting

| Task | Git | jj | Notes |
|---|---|---|---|
| Rebase | `git rebase <base>` | `jj rebase -d <dest>` | Descendants follow automatically |
| Rebase range | `git rebase --onto <new> <old> <head>` | `jj rebase -s <source> -d <dest>` | |
| Rebase single commit | `git cherry-pick` (sort of) | `jj rebase -r <rev> -d <dest>` | |
| Cherry-pick | `git cherry-pick <ref>` | `jj duplicate <rev>` | Independent copy |
| Revert | `git revert <ref>` | `jj revert -r <rev>` | Required: `--onto` / `-A` / `-B` |
| Interactive rebase | `git rebase -i` | combine `jj rebase`, `jj squash`, `jj edit`, `jj abandon` | No single command |
| Squash last N | `git rebase -i HEAD~N` (squash) | `jj squash --from <rev>` | |
| Absorb hunks | (manual) | `jj absorb` | Routes hunks to ancestors that last touched those lines |
| Parallelize | (manual) | `jj parallelize <revs>` | Convert serial commits to siblings |
| Edit metadata only | `git commit --amend --no-edit --date` | `jj metaedit -r <rev>` | Without changing tree |

## Stashing / Context Switching

| Task | Git | jj | Notes |
|---|---|---|---|
| Stash | `git stash` | `jj new` | Old work stays in `@-`; `@` is fresh |
| Stash pop | `git stash pop` | `jj edit <change-id>` | Resume editing the previous change |
| Stash specific files | `git stash push <file>` | `jj commit -m "wip" file && jj new` | |

## Undoing / Restoring

| Task | Git | jj | Notes |
|---|---|---|---|
| Undo last action | `git reflog` + `git reset` | `jj undo` | Single command |
| Restore file | `git checkout -- <file>` | `jj restore <file>` | Default `--from @-` |
| Restore from rev | `git checkout <rev> -- <file>` | `jj restore --from <rev> <file>` | |
| Restore all | `git checkout .` | `jj restore` | |
| Hard reset to parent | `git reset --hard HEAD~1` | `jj abandon` | |
| Operation history | `git reflog` | `jj op log` | Whole-repo history, atomic |
| Time travel | `git reset --hard <reflog-id>` | `jj op restore <op-id>` | Restore the entire repo state |

## Workspace / Worktree

| Task | Git | jj | Notes |
|---|---|---|---|
| Add worktree | `git worktree add <path>` | `jj workspace add <path> --name <n>` | Shared commit graph |
| List worktrees | `git worktree list` | `jj workspace list` | |
| Remove worktree | `git worktree remove <path>` | `jj workspace forget <name>` | Then delete the directory |
| Update stale | N/A | `jj workspace update-stale` | Re-sync after another workspace rewrote `@` |
| Workspace root | `git rev-parse --show-toplevel` | `jj workspace root` | |

## Fileset Patterns

Used wherever jj accepts file arguments:

| Pattern | Meaning |
|---|---|
| `file.txt` | Exact file |
| `glob:src/**/*.rs` | Glob pattern |
| `root:path` | Path relative to repo root (not cwd) |
| `a \| b` | Union |
| `a & b` | Intersection |
| `~a` | Complement (all except `a`) |
| `all()` | All files |
| `none()` | No files |

## Things Git Has That jj Doesn't (and vice versa)

- **No `git add`/staging area** in jj — every file change is automatically part of `@`. To exclude a file from a commit, either move it out with `jj restore` or `jj split` it into a sibling commit.
- **No `git stash`** in jj — `jj new` accomplishes the same thing because the old work stays in the parent commit and you can `jj edit` back to it.
- **`jj absorb`** has no git equivalent — auto-routes hunks of `@` to whichever ancestor commits last modified those lines.
- **`jj op log`** is much more powerful than `git reflog`: it's atomic across all refs and the full operation graph is replayable.
- **First-class conflicts** — `jj rebase` never fails on conflict; the conflict is recorded in the rebased commit and can be resolved later (or even in a different commit).
- **`git submodule`/`git lfs`** have no jj equivalent — drop to git for those (in colocated repos).
