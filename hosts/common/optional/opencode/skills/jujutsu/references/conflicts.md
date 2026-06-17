# First-Class Conflicts

Unlike Git, jj **stores conflicts in commits**. `jj rebase`, `jj new`, `jj merge` etc. never fail because of merge conflict — the conflict is recorded inside the resulting commit. You can resolve it later, even in a different commit.

This means:

- No `git rebase --continue` workflow. If a rebase produces conflicts, the rebase still succeeds; you resolve the conflicts whenever you want.
- Auto-rebase: when you rewrite a commit, all descendants get rebased automatically. If those rebases conflict, the conflict travels with them.
- Conflict resolutions in merge commits are preserved across rebase (much of `git rerere`'s use case is gone).

## Detecting Conflicts

```bash
jj st              # lists conflicted files
jj log             # conflicted commits show a red "conflict" label
jj log -r 'conflicts()'   # list every conflicted commit in the repo
```

## Resolving Conflicts

The agent-friendly approach: **edit the conflicted files directly in your working copy**, removing the conflict markers and replacing them with the resolved content. After saving, run `jj st` — jj re-parses the file and the conflict label disappears automatically.

Don't use `jj resolve` — it launches an interactive merge tool.

If a conflict was introduced upstream of your current commit, you have two options:

1. **Resolve in `@`**: `jj new <conflicted-commit>`, edit files, then `jj squash` to fold the resolution back into the conflicted commit.
2. **Resolve in place**: `jj edit <conflicted-commit>`, edit files. The disadvantage is that you can't easily inspect the resolution as a diff.

## Conflict Marker Format (jj's default style)

jj's default markers carry more information than git's, because they include both a "snapshot" of one side and a "diff" describing how the *other* side(s) differ from the merge base. Example:

```text
<<<<<<< conflict 1 of 1
%%%%%%% diff from: vpxusssl 38d49363 "merge base"
\\\\\\\        to: rtsqusxu 2768b0b9 "commit A"
 apple
-grape
+grapefruit
 orange
+++++++ ysrnknol 7a20f389 "commit B"
APPLE
GRAPE
ORANGE
>>>>>>> conflict 1 of 1 ends
```

- `<<<<<<<` / `>>>>>>>` — start and end of a single conflict region
- `%%%%%%%` — start of a *diff* (apply this diff to the snapshot below it)
- `+++++++` — start of a *snapshot* (a literal version of the file region)
- `\\\\\\\` — line continuation for labels

In this example: take the uppercase snapshot (commit B), then apply the `grape → grapefruit` diff to it, yielding:

```text
APPLE
GRAPEFRUIT
ORANGE
```

To resolve, replace the entire `<<<<<<<...>>>>>>>` block with the resolved text.

### N-way conflicts

Conflicts can have more than 2 sides (e.g. when merging 3+ commits). You'll see one snapshot and multiple diff sections. Resolve by applying each diff to the snapshot in turn.

## Alternative Marker Styles

Set `ui.conflict-marker-style` in `~/.config/jj/config.toml`:

### `snapshot` style — show each side as a literal snapshot

```text
<<<<<<< conflict 1 of 1
+++++++ rtsqusxu 2768b0b9 "commit A"
apple
grapefruit
orange
------- vpxusssl 38d49363 "merge base"
apple
grape
orange
+++++++ ysrnknol 7a20f389 "commit B"
APPLE
GRAPE
ORANGE
>>>>>>> conflict 1 of 1 ends
```

### `git` style — git's diff3 markers (2-sided conflicts only)

```text
<<<<<<< rtsqusxu 2768b0b9 "commit A"
apple
grapefruit
orange
||||||| vpxusssl 38d49363 "merge base"
apple
grape
orange
=======
APPLE
GRAPE
ORANGE
>>>>>>> ysrnknol 7a20f389 "commit B"
```

For >2 sides, jj falls back to the snapshot style automatically.

## Long Conflict Markers

If a file might contain literal `=======` or `<<<<<<<` lines, jj uses *longer* markers (15 chars instead of 7) to disambiguate:

```text
<<<<<<<<<<<<<<< conflict 1 of 1
%%%%%%%%%%%%%%% diff from: ...
...
>>>>>>>>>>>>>>> conflict 1 of 1 ends
```

When editing, match the marker length you see.

## Missing-Newline Conflicts

If a side of the conflict has no trailing newline, jj annotates the marker with `(no terminating newline)`. Example:

```text
<<<<<<< conflict 1 of 1
+++++++ tlwwkqxk d121763d "commit A" (no terminating newline)
grapefruit
%%%%%%% diff from: qwpqssno fe561d93 "merge base" (no terminating newline)
\\\\\\\        to: poxkmrxy c735fe02 "commit B"
-grape
+grape
>>>>>>> conflict 1 of 1 ends
```

If you don't care whether the file ends with a newline, you can ignore the annotation and resolve normally. If you do care, control the trailing newline of your replacement deliberately.

## Conflicts on Bookmarks (Not Files)

A *bookmark* can also be conflicted: e.g. you moved `main` locally, and `main` was also moved on the remote in a way that doesn't fast-forward. `jj bookmark list` shows it with a `?` and `jj log` shows multiple positions. Resolve with:

```bash
jj bookmark set main -r <correct-commit>
```

This explicitly chooses one position. See `references/bookmarks.md` for details.

## Why First-Class Conflicts Matter

- **Single resolution workflow**: always "check out commit, edit files, done."
- **Postpone resolution**: rebase a stack of WIP commits onto upstream's head and resolve conflicts when you're ready, without `--continue` interruptions.
- **Collaborative resolution**: conflicts can be shared with others (caveat: don't push them to a Git remote that other Git users will pull from).
- **Octopus and criss-cross merges**: become trivial implementation-wise; jj can resolve some cases that Git cannot.
