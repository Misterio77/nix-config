# My NixOS configurations

Here's my NixOS/home-manager config files. Requires [Nix flakes](https://nixos.wiki/wiki/Flakes).

Looking for something simpler to start out with flakes? Try [my starter config repo](https://github.com/Misterio77/nix-starter-config).

## Structure
- `flake.nix`: Entrypoint for hosts and home configurations. Also exposes a devshell for boostrapping (`nix develop`).
- `hosts`: System-wide configuration for my machines. Accessible via `nixos-rebuild --flake`.
  - `atlas`: Desktop PC - 32GB RAM, R5 3600x, RX 5700XT | Sway
  - `pleione`: Lenovo Ideapad 3 - 8GB RAM, R7 5700u | Sway
  - `merope`: Raspberry Pi 4 - 8GB RAM | Server
  - `maia`: Gf's PC - 16GB RAM, i5 6600, GTX 970 | GNOME
- `users`: Home-manager configurations for my user(s). Acessible via `home-manager --flake`
  - `misterio`: That's me!
  - `layla`: My sweet sweet girl
- `modules`: A few modules i have for personal use.
- `overlays`: Patches and version overrides for some packages. Accessible via `nix build`.
- `pkgs`: Some of my custom packages. There's a few others at [my NUR](https://github.com/misterio77/nur-packages). Also accessible via `nix build`.
- `templates`: A couple project templates for different languages. Accessible via `nix init`.


## About the installation
This is hardware specific and can easily be changed by switching out `hardware-configuration.nix` files.

All my computers use a single btrfs (encrypted on all except headless) partition, with subvolumes for `/nix`, a `/persist` directory (which I opt in using `impermanence`), swap file, and a root subvolume cleared on every boot.

Home-manager is used in a standalone way, and because of opt-in persistence is activated on every boot with `loginShellInit`.


## How to bootstrap

All you need is bash, nix, and git. Just `nix develop`, and you should be good to go.

`nixos-rebuild --flake .` To build system configuration

`home-manager --flake .` To build user configuration
