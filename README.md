[![builds.sr.ht status](https://builds.sr.ht/~misterio/nix-config.svg)](https://builds.sr.ht/~misterio/nix-config)
[![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://builtwithnix.org)

# My NixOS configurations

Here's my NixOS/home-manager config files. Requires [Nix flakes](https://nixos.wiki/wiki/Flakes).

Looking for something simpler to start out with flakes? Try [my starter config repo](https://github.com/Misterio77/nix-starter-config).

## Structure
- `flake.nix`: Entrypoint for hosts and home configurations. Also exposes a devshell for boostrapping (`nix develop`).
- `hosts`: System-wide configuration for my machines. Accessible via `nixos-rebuild --flake`.
  - `atlas`: Desktop PC - 32GB RAM, R5 3600x, RX 5700XT | Sway
  - `pleione`: Lenovo Ideapad 3 - 8GB RAM, R7 5700u | Sway
  - `merope`: Raspberry Pi 4 - 8GB RAM | Server
- `users`: Home-manager configurations for my user(s). Acessible via `home-manager --flake`
  - `misterio`: That's me!
- `modules`: A few modules i have for personal use.
- `overlays`: Patches and version overrides for some packages. Accessible via `nix build`.
- `pkgs`: My custom packages. Also accessible via `nix build`. You can compose these into your own configuration by using my flake's overlay or through NUR.
- `templates`: A couple project templates for different languages. Accessible via `nix init`.


## About the installation
This is hardware specific and can easily be changed by switching out `hardware-configuration.nix` files.

All my computers use a single btrfs (encrypted on all except headless systems) partition, with subvolumes for `/nix`, a `/persist` directory (which I opt in using `impermanence`), swap file, and a root subvolume (cleared on every boot).

Home-manager is used in a standalone way, and because of opt-in persistence is activated on every boot with `loginShellInit`.


## How to bootstrap

All you need is bash, nix, and git. Just `nix develop`, and you should be good to go.

`nixos-rebuild --flake .` To build system configuration

`home-manager --flake .` To build user configuration

## Secrets

On my desktop and laptop, I use `pass` for managing passwords, which are encrypted using PGP together with a YubiKey. I use this same PGP keychain for SSH, so secrets are easy to grab from a fresh host.

Secrets on my headless pi (merope) are stored on the persist directories (usually `/srv`), I don't bother managing them since they're easily rotated if needed.

## Unixpornish stuff
![screenshot](https://preview.redd.it/q8z05dsvrvb81.png?width=960&crop=smart&auto=webp&s=d66264a468c0ca194cc8cbb2ab80829eea7921a7)

That's how my sway setups (desktop and laptop) look like.

If you're interested in my WM configurations, they're managed by home-manager and are located at `users/misterio/home/desktop-sway`.
