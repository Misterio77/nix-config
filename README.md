# My NixOS configurations

Here's my NixOS/home-manager config files. Requires [Nix flakes](https://nixos.wiki/wiki/Flakes).

## Structure
- `flake.nix`: Entrypoint for both hosts (`nixos-rebuild --flake`) and home configurations (`home-manager --flake`). Also exposes a devshell for boostrapping (`nix develop`).
- `hosts`: System-wide configuration for my machines.
  - `atlas`: Desktop PC - 32GB RAM, R5 3600x, RX 5700XT | Sway
  - `pleione`: Lenovo Ideapad 3 - 8GB RAM, R7 5700u | Sway
  - `merope`: Raspberry Pi 4 - 8GB RAM | Server
  - `maia`: Gf's PC - 16GB RAM, i5 6600, GTX 970 | GNOME
- `users`: Home-manager configurations for my user(s)
  - `misterio`: That's me!
  - `layla`: My sweet sweet girl
- `modules`: A few modules i have for personal use (most should be upstreamed TBH)
- `overlays`: Patches and version overrides for some packages. Also callPackages stuff in `pkgs`.
- `pkgs`: Some of my custom packages. There's a few others at [my NUR](https://github.com/misterio77/nur-packages).
- `templates`: A couple project templates for different languages. Accessible via `nix init`.


## About the installation
This is hardware specific and can easily be changed by switching out `hardware-configuration.nix` files.

I use a erase my darlings-like setup. My desktop pc uses an encrypted btrfs partition, which has subvolumes for nix store, games, home (snapshotted), srv (snapshotted), and var. The pi is similar, but with a single ext4 partition for all that. The root filesystem is a tmpfs, on which the partitions are mounted to achieve opt-in state.

I use home-manager as a standalone module, and, as such, i have to "manually" activate it. For this reason, i have a hook on loginShell that activates it, if not already active.


## How to bootstrap

All you need is bash, nix, and git. Just `nix develop`, and you should be good to go.

`nixos-rebuild --flake .` To build system configuration

`home-manager --flake .` To build user configuration
