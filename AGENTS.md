# NixConfig Conventions for LLMs

## Commit Messages

Conventional commits: `type(scope): description`

- `type`: `feat`, `fix`, `refactor`, `chore`, `WIP`
- `scope`: path-based, reflecting what part of the config changed. Examples:
  - `home/{feature}` for home-manager features: `home/calendar`, `home/opencode`, `home/helix`
  - `{host}` or `{host}/{service}` for host-specific: `pleione`, `alcyone/firefly`, `merope/recyclarr`
  - Just the component for shared/global: `grafana`, `minecraft`, `recyclarr`
- Message is lowercase, no period at end.
## Directory Structure

```
.
├── home/gabriel/          # Home Manager user config
│   ├── features/          #   Feature modules (cli/, desktop/, productivity/, helix/, etc.)
│   │   └── {feature}/
│   │       ├── default.nix  # Feature flag + imports
│   │       └── *.nix        # Specific tool configs
│   ├── global/            #   Always-imported config (xdg, etc.)
│   ├── {hostname}.nix     #   Per-host home-manager config
│   └── generic.nix        #   Non-impermanence fallback
├── hosts/                 # NixOS host configs
│   ├── common/            #   Shared across hosts
│   │   ├── global/        #     Always-imported
│   │   ├── optional/      #     Opt-in modules
│   │   └── secrets.yaml   #     SOPS-encrypted shared secrets
│   └── {hostname}/        #   Per-host (atlas, maia, alcyone, celaeno, merope, pleione, taygeta)
│       ├── default.nix    #     NixOS module
│       ├── hardware-configuration.nix
│       └── secrets.yaml   #     Host-specific secrets (optional)
├── modules/               # Custom NixOS & HM modules
│   ├── nixos/
│   └── home-manager/
├── overlays/              # Package overlays and patches
│   └── default.nix
├── pkgs/                  # Custom packages
│   └── default.nix
├── templates/             # Project templates
├── flake.nix              # Flake entry point
├── deploy.sh              # nixos-rebuild wrapper
└── .sops.yaml             # SOPS encryption keys
```

## Code Style

- **Formatter**: Alejandra (`nix fmt <file>`). ALWAYS format after edits. Never format unmodified files.
- **Indentation**: 2 spaces, no tabs.
- **Line endings**: LF, final newline, trimmed trailing whitespace.
- **Nix conventions**:
  - Top-level modules are functions taking `{pkgs, lib, config, inputs, ...}`.
  - Use `lib` from `nixpkgs.lib // home-manager.lib` (merged, already in `outputs.lib`).
  - Feature-flag modules use a `default.nix` with a boolean `enable` option gating imports.
  - Prefer `lib.mkOption` / `lib.mkEnableOption` for new options.

## Secrets

- Managed with **sops-nix**, keys defined in `.sops.yaml`.
- Two types of secret files:
  - `hosts/common/secrets.yaml` -- shared across hosts, encrypted to all host age keys.
  - `hosts/{hostname}/secrets.yaml` -- per-host, encrypted to that host only.
- Both are also encrypted to the PGP key `7088C7421873E0DB97FF17C2245CAB70B4C225E9`. It lives on misterio's yubikey.
- **Never** read secrets into context. Ask the user to do it.

## Building and Deploying

- Format check: `nix fmt`
- Build a host: `nixos-rebuild build --flake .#{host}`
- Deploy a host: `./deploy.sh {host}`
- Home-manager standalone: `home-manager switch --flake .#{user}@{host}`
- CI/CD: Hydra at `hydra.m7.rs` builds all hosts on push; hosts auto-upgrade from the latest successful build (see `modules/nixos/hydra-auto-upgrade.nix`).

## Vdirsyncer Calendar Collections

When adding a remote calendar collection to `home/gabriel/features/productivity/calendar.nix`:

1. First verify the collection exists remotely with `vdirsyncer discover`.
2. Add the collection name (or UUID) string to the `collections` list under the appropriate account.
3. Use a `# Comment` to note the display name if it differs from the ID.
