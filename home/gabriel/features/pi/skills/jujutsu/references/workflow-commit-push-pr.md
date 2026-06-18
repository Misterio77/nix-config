# Workflow: Commit, Push Bookmark, Open PR

The exact step-by-step for shipping a change as a GitHub PR. Activate this when the user wants to commit, push, ship, finalize, or open a PR.

## 1. Pre-flight

```bash
jj st
jj bookmark list
```

Confirm:
- There are tracked changes in `@` (or `@-` if you've already committed).
- You know which bookmark this work belongs to.

In a colocated repo, sanity-check that the agent has write access to `.git`:

```bash
if [ -d .jj ] && [ -d .git ]; then
  probe=$(mktemp .git/.write-test.XXXXXX 2>/dev/null) && rm -f "$probe"
fi
```

If the probe fails (e.g. read-only sandbox), **stop**. Don't attempt `jj commit`, `jj git push`, or any git fallback. Tell the user the session can edit files but not perform VCS writes, and ask them to ship from a local shell.

If no bookmark exists for this work, create one *before* committing so it tracks the change ID:

```bash
jj bookmark create <feature-name> -r @
```

## 2. Commit

```bash
jj commit -m "<conventional-commit-message>"
```

After `jj commit`:
- The content lives in `@-` (the parent).
- A new empty `@` is created on top.

## 3. Verify the bookmark

```bash
jj bookmark list
```

The bookmark should point at `@-`. If you used `jj bookmark create -r @` *before* committing, it follows the change ID automatically and is already correct. If not, advance it explicitly:

```bash
jj bookmark set <feature-name> -r @-
```

## 4. Push

```bash
jj git push -b <feature-name>
```

`jj git push` automatically force-pushes if the bookmark was rewritten. It refuses if the remote bookmark moved unexpectedly (similar to `git push --force-with-lease`); if that happens, run `jj git fetch`, resolve any bookmark conflict, and push again.

## 5. Open the PR

```bash
gh pr create --base main --head <feature-name> \
  --title "<title>" --body "<body>"
```

- Use the commit message subject line as the PR title by default.
- For the body, ask the user for any extra context, or use the commit message body if it's substantial.
- If `gh` doesn't work (e.g. in a workspace without `.git/`), see `references/workflow-new-workspace.md` for the `$GIT_DIR` wiring step.

## 6. Show the result

```bash
jj log -r '@ | @-'
```

Return the PR URL to the user.

## Conventional Commit Message Format

Prefer the imperative, sentence-case "verb object" style without a trailing period:

- `feat: add user authentication to login endpoint`
- `fix: null pointer in payment processor`
- `refactor: extract validation helper`
- `docs: clarify push safety semantics`
- `test: cover divergent bookmark resolution`

Each commit should represent **one logical change**. Use `jj squash` and `jj absorb` to refine before pushing if a change has crept beyond its intended scope.
