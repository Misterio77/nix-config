---
name: nix-shell
description: Use `nix shell` for ephemeral environments and one-off commands without installing packages globally.
---

## nix shell

The canonical form for running a single command in a temporary nix environment:

```
nix shell nixpkgs#<package> -c <command> [args...]
```

The `-c` flag tells `nix shell` to exec the following arguments as a command.
Everything after `-c` is passed straight to the shell, so quoting works naturally.

### Single-package one-off

```bash
nix shell nixpkgs#jq -c jq '.foo' file.json
nix shell nixpkgs#yq -c yq eval '.foo.bar' file.yml
nix shell nixpkgs#httpie -c https httpbin.org/json
```

### Multiple packages in one shell

For ephemeral environments with multiple tools (where the "command" is `sh`):

```bash
nix shell nixpkgs#jq nixpkgs#yq nixpkgs#curl -c sh
```

This drops you into an interactive shell with all three available. Exit with `exit` or `^D`.

### When to use `nix run` instead

`nix run` is more concise when you just need to run a tool's default binary and
don't need to control the invoked command name:

```bash
nix run nixpkgs#jq -- -r '.name' file.json
```

Use `nix run` when:
- You want a single command with arguments (everything after `--` is passed to the binary)
- The package's default binary name matches what you need
- You don't need multiple packages simultaneously

Use `nix shell` when:
- You need to chain multiple commands in the same ephemeral environment
- The command name differs from the package name (e.g., `nixpkgs#nodePackages.prettier`)
- You want an interactive shell with multiple tools available

### Finding available packages

```bash
nix search nixpkgs <query>
```

### Replacing missing commands

If a command fails with "command not found", wrap it with nix shell instead of
installing the package globally:

```bash
# instead of: apt install jq  (never)
# instead of: nix profile install nixpkgs#jq  (avoid for one-offs)
nix shell nixpkgs#jq -c jq '.foo' data.json
```
