---
description: Write a markdown note under ~/Notes
argument-hint: "<topic/details>"
---
Write a concise markdown note somewhere under `~/Notes` about: $ARGUMENTS

Workflow:
1. Use the `gabs-tools` skill if available, since this touches `~/Notes`.
2. `~/Notes` is a jj repository. Before editing, inspect state with `jj st` and `jj log`; if the current change is not empty or is already described, start a fresh change with `jj new`.
3. Infer the best location under `~/Notes` from context (for example `Personal/`, `Elisa/`, project-specific folders, or another existing area). If unsure, ask instead of guessing wildly.
4. Create a separate, clearly named markdown file; do not append to an unrelated existing note unless I explicitly ask for that.
5. Do not assume drafts, code changes, or other context exist. If I refer to a diff, command, URL, or file, inspect/read it first and summarize what it actually says.
6. Keep the note factual and useful for future me: context, relevant paths/commands, open questions, and concrete next steps.
7. After writing, verify with `jj st` in `~/Notes`, then describe the Notes jj change with a concise conventional-commit style message and the required `Assisted-by: <harness> (<model>)` trailer.
8. Verify with `jj st` / `jj log` afterwards and tell me the note path plus the commit description.
