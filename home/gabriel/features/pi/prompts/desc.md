---
description: Describe or commit the current VCS change
argument-hint: "[instructions]"
---
Describe/commit the current VCS change. Extra instructions from me, if any: $ARGUMENTS

Workflow:
1. Identify the harness/model first with `ps -fp $PPID` if you have not already done so in this session.
2. Inspect repository state before mutating anything:
   - If `.jj/` exists, use Jujutsu only: `jj st`, `jj log`, and `jj diff`.
   - Otherwise if `.git/` exists, use Git: `git status --short`, `git diff --cached`, and `git diff`.
3. Review whether the change should be split before describing it.
4. Keep unrelated changes out. If the working tree/change contains unrelated work, ask me before bundling it.
5. Write a concise conventional-commit style message matching the repo's conventions when available.
6. Include an `Assisted-by: <harness> (<model>)` trailer in the commit/description.
7. Apply it non-interactively:
   - Jujutsu: `jj describe -m $'subject\n\nbody\n\nAssisted-by: ...'` on the current change.
   - Git: commit staged changes with `git commit -m ...`; do not stage unstaged files unless I explicitly asked you to.
8. Verify with status/log afterwards.
