# My NixOS configurations

Here's my NixOS/home-manager config files. Requires [Nix experimental command and flakes](https://nixos.wiki/wiki/Flakes).

## Structure
- `flake.nix`: Entrypoint for both hosts (`nixos-rebuild --flake`) and home configurations (`home-manager --flake`). Also exposes a devshell for boostrapping (`nix develop` or `nix-shell`).
- `hosts`: System-wide configuration for my machines.
  - `atlas`: Desktop PC - 32GB RAM, R5 3600x, RX 5700XT | Runs sway. Development, production, and gaming.
  - `merope`: Raspberry Pi 4 - 8GB RAM | Headless. Server usage.
- `users`: Home-manager configurations for my user(s)
  - `misterio`: That's me!
- `modules`: A few modules i have for personal use (most should be upstreamed TBH)
- `overlays`: A few custom packages (TODO make actual packages) and overwritten ones.


## About the installation
This is hardware specific and can easily be changed by switching out `hardware-configuration.nxi` files.

I use a erase my darlings-like setup. My desktop pc uses an encrypted btrfs partition, which has subvolumes for nix store, games, home (snapshotted), srv (snapshotted), and var. The pi is similar, but with a single ext4 partition for all that. The root filesystem is a tmpfs, on which the partitions are mounted to achieve opt-in state.

I use home-manager as a standalone module, and, as such, i have to "manually" activate it. For this reason, i have a hook on loginShell that activates it, if not already active.


## How to bootstrap

All you need is bash, nix, and git. Just `nix-shell` (or `nix develop`, if already on flakes), and you should be good to go.

`nixos-rebuild --flake .` To build system configuration

`home-manager --flake .` To build user configuration
