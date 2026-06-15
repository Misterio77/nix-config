# Operation Log, Undo, and Recovery

Every `jj` command that mutates the repo records an **operation**. The set of operations forms a DAG (the *operation log*), which is jj's equivalent of `git reflog` — but more powerful: it's atomic across all bookmarks and the working copy, and it lets you replay or rewind the entire repo state, not just per-ref histories.

## Inspecting

```bash
jj op log                       # full operation history
jj op log --limit 20            # most recent 20
jj op show @                    # details of the most recent operation
jj op show <op-id> -p           # details with patch
```

Each operation contains a **view**: a snapshot of bookmarks, tags, Git refs, visible heads, and the working-copy commit at the end of the operation, plus metadata (timestamps, host, user, description).

In `jj op log`, `@` refers to the *current* operation (similar to how `@` refers to the working-copy commit elsewhere). Operators `@-` and `@+` walk parent/child operations.

## Undo

```bash
jj undo            # reverse the most recent operation
jj op revert <id>  # reverse a specific (non-most-recent) operation
jj op restore <id> # rewind the entire repo to that operation's state
```

`jj undo` is the safest possible escape hatch — it works for almost everything (accidental abandon, bad rebase, wrong squash, mistaken describe, etc.). When in doubt, undo first and re-investigate.

## Loading the Repo at a Past Operation

`--at-operation` (or `--at-op`) is a top-level flag accepted by *any* jj command. It loads the repo state as of a specific operation:

```bash
jj --at-op <op-id> log
jj --at-op <op-id> diff
jj --at-op <op-id> file show path/to/file
```

When `--at-op` is used:

- **No working-copy snapshot is taken.** Your working copy is not committed.
- `@` resolves to the working-copy commit *as recorded in that operation's view*, not your current working copy.
- You can run *any* command, but typically you only want read-only ones (`log`, `st`, `diff`, `show`, `file show`). Mutating commands work but simulate "what if I had run this back then" — usually not what you want.

## Recovering Lost Files from Snapshot History

jj automatically snapshots the working copy at the start of (almost) every command. So if you accidentally edited or deleted a file *and then ran a jj command*, the previous version is preserved as a snapshot operation.

To find every snapshot operation:

```bash
jj op log --no-graph -T 'if(self.snapshot(), self.id() ++ "\n")'
```

To restore a file from the most recent snapshot in which it existed:

```bash
jj op log --no-graph -T 'if(self.snapshot(), self.id() ++ "\n")' \
  | while read -r op; do
      if jj --at-op="$op" file show path/to/file >/dev/null 2>&1; then
        jj --at-op="$op" file show path/to/file > path/to/file
        break
      fi
    done
```

**Important caveat:** This only works for states that were captured by a snapshot. If you edited a file and then deleted it *without running any jj command in between*, the intermediate state was never snapshotted and cannot be recovered.

## Concurrent / Divergent Operations

The operation log enables lock-free concurrency: you can run jj commands in parallel (even from different machines on a shared filesystem) without corrupting the repo. When two commands run concurrently, both see the same starting state and write divergent operations. The operation log forks and merges to record this.

If you ever see `jj log` reporting a divergent change after running concurrent commands, that's the operation log telling you it serialized two parallel branches. You can `jj op log` to inspect what happened and `jj op restore` to pick a side.

## When to Use What

| Situation | Use |
|---|---|
| Just made a mistake | `jj undo` |
| Accidentally squashed/abandoned/rebased something a few ops ago | `jj op log` to find it, then `jj op restore <op-id>` |
| Need to inspect "what did this look like yesterday" | `jj --at-op <op-id> log` |
| Lost a file by editing/deleting after a `jj` command ran | Snapshot scan above |
| Divergent change appeared from concurrent commands | `jj op log` to understand, `jj abandon` the wrong side |
| `Working copy is stale` error | `jj workspace update-stale` (separate from op log; see `references/workspaces.md`) |
