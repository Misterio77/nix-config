# Glossary

Condensed from the [official jj glossary](https://jj-vcs.github.io/jj/latest/glossary/). For canonical wording, see the source.

### Anonymous branch
A chain of commits with no bookmark pointing to it. Unlike Git, jj keeps anonymous branches around until they are explicitly abandoned.

### Backend
The storage layer. The production-ready commit backend is the **Git backend**, which stores commits in a Git repository. There are also test backends and Google's internal cloud backend.

### Bookmark
A named pointer to a commit. Similar to Git branches and Mercurial bookmarks, but: there is no "current bookmark," and bookmarks do *not* automatically advance when you create new commits — they *do* follow rewritten commits by change ID.

### Branch (the word, in jj context)
Usually means an *anonymous* branch (a chain of commits) or a branch of the commit DAG. Git's notion of a branch corresponds to a *bookmark* in jj. In a colocated repo, each local Git branch ↔ a jj bookmark of the same name.

### Change
A commit *as it evolves over time* — a sequence of commits sharing a change ID. The "change" itself isn't an object in the data model; only the change ID is, and it's a property of the commit.

### Change ID
A stable identifier for a change. 16 bytes, displayed as 12 letters in the k-z range (these are hex digits using `z-k` instead of `0-9a-f`). Change IDs persist across rewrites — that's their main superpower over commit IDs.

### Change offset
A disambiguation suffix when a change ID matches multiple commits (e.g. `xyz/0` for the most recent, `xyz/1` for the previous). Used for divergent or hidden changes.

### Colocated workspace
A workspace where `.jj/` and `.git/` are siblings. Most Git tools work on it; `jj` and `git` commands are interchangeable for reads. Mutations should go through `jj`.

### Commit
A snapshot of files (a tree) plus metadata (author, date, parent pointers). Commits form a DAG. Even though commits are stored as snapshots, they're often *treated* as differences relative to their parent(s).

### Commit ID
A 20-byte unique identifier for a commit (Git backend = Git commit ID), displayed as 12 hex digits by default. Changes when the commit's content changes.

### Conflict
Most commonly, **file conflicts** — recorded inside commits via conflict markers. Can also occur on **bookmarks** (a bookmark moved both locally and remotely in incompatible ways) and on **changes** (the same change rewritten in two places — see *divergent change*).

### Divergent change
A change with more than one visible commit. Displayed in `jj log` with a change offset suffix (`xyz/0`, `xyz/1`).

### Head
A commit with no descendants *in some context*. The view records visible anonymous heads. The `heads(X)` revset function returns commits in `X` that have no descendants in `X`. **Note:** unrelated to Git's `HEAD`.

### Hidden / abandoned commit
A commit that is no longer visible — e.g. it was abandoned, or it's an older version of a rewritten change. Hidden commits aren't returned by `jj log` by default; you can still reach them by commit ID or `at_operation()`.

### Operation
A snapshot of visible commits + bookmarks at a point in time, plus metadata (user, host, timestamp). Operations form a DAG (the operation log).

### Operation log
The DAG of operation objects, similar to a commit DAG but for repo state changes rather than file changes. Replaces Git's reflog.

### Remote
A reference to another copy of the repo. Usually hosted at a Git provider (GitHub/GitLab/Codeberg/etc).

### Repository
Everything under `.jj/` — the full set of operations and commits.

### Revision
Synonym for **commit**.

### Revset
An expression in jj's functional language for selecting commits. Also informally used for the *result set* of such an expression. See `references/revsets.md`.

### Rewrite
To create a new version of a commit (different content, metadata, or parents). Rewriting yields a new commit ID but preserves the change ID. Rebasing, amending, and editing the working copy all rewrite commits.

### Root commit
A virtual commit that's the ancestor of every other commit. Commit ID `0000...`, change ID `zzzz...`, referenced as `root()` in revsets. **Note:** different from Git's "root commits" (which are the first real commits in the repo).

### Tracked / tracking bookmark
A *tracked remote bookmark* is a remote bookmark that jj keeps in sync with a local bookmark. The local one is the *tracking bookmark*. Use `jj bookmark track <name>@<remote>` to make a remote bookmark tracked.

### Tree
A snapshot of a directory in the repo (recursive). Each commit references a tree.

### View
A snapshot of bookmarks, anonymous heads, and working-copy commits. Each operation records a view. The view is what determines which commits are *visible*.

### Visible commits
Commits returned by `jj log -r 'all()'` — those reachable from a visible head, plus their ancestors. Abandoned/rewritten commits become hidden.

### Working copy
The files on disk that you're editing. jj automatically snapshots the working copy into the **working-copy commit** at the start of (almost) every command. Git calls this the "working tree."

### Working-copy commit
The commit that represents the current state of the working copy (`@`). One per workspace.

### Workspace
A working copy + an associated repository. A repo can have many workspaces, each with its own `@`. Equivalent to Git's *worktree*.
