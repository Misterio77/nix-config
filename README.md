[![builds.sr.ht status](https://builds.sr.ht/~misterio/nix-config.svg)](https://builds.sr.ht/~misterio/nix-config)
[![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://builtwithnix.org)

# My NixOS configurations

Here's my NixOS/home-manager config files. Requires [Nix flakes](https://nixos.wiki/wiki/Flakes).

Looking for something simpler to start out with flakes? Try [my starter config repo](https://github.com/Misterio77/nix-starter-config).

**Highlights**:
- **Opt-in persistence** through impermanence + blank snapshotting
- **Encrypted** single **BTRFS** partition
- Multiple **NixOS configurations**, including **desktop**, **laptop**, **server**
- Deployment **secrets** using **sops-nix**
- Flexible **Home Manager** Configs through **feature flags**
- Extensively configured **sway** and **neovim**
- Fully **declarative** **self-hosted** stuff
- **Mesh networked** hosts with **tailscale** and **headscale**

## Structure
- `flake.nix`: Entrypoint for hosts and home configurations. Also exposes a
  devshell for boostrapping (`nix develop`).
- `lib`: A few lib functions for making my flake cleaner
- `nixos`: NixOS Configurations, accessible via `nixos-rebuild --flake`.
  - `hosts`: My machines, and their specific configurations
    - `atlas`: Desktop PC - 32GB RAM, R5 3600x, RX 5700XT | Sway
    - `pleione`: Lenovo Ideapad 3 - 8GB RAM, R7 5700u | Sway
    - `merope`: Raspberry Pi 4 - 8GB RAM | Server
  - `common`: Shared configurations consumed by the machine-specific ones.
    - `global`: Configurations that are globally applied to all my machines.
    - `optional`: Opt-in configurations my machines can use.
- `home-manager`: My Home-manager configuration, acessible via `home-manager --flake`
    - Each directory here is a "feature" each hm configuration can toggle, thus
      customizing my setup for each machine (be it a server, desktop, laptop,
      anything really).
- `modules`: A few actual modules (with options) I haven't upstreamed yet.
- `overlay`: Patches and version overrides for some packages. Accessible via
  `nix build`.
- `pkgs`: My custom packages. Also accessible via `nix build`. You can compose
  these into your own configuration by using my flake's overlay, or consume them through NUR.
- `templates`: A couple project templates for different languages. Accessible
  via `nix init`.


## About the installation

All my computers use a single btrfs (encrypted on all except headless systems)
partition, with subvolumes for `/nix`, a `/persist` directory (which I opt in
using `impermanence`), swap file, and a root subvolume (cleared on every boot).

Home-manager is used in a standalone way, and because of opt-in persistence is
activated on every boot with `loginShellInit`.


## How to bootstrap

All you need is nix (2.4+), and git. Then run:
```bash
nix --extra-experimental-features="nix-command flakes" develop
```

`nixos-rebuild --flake .` To build system configurations

`home-manager --flake .#` To build user configurations

`nix build` (or shell or run) To build and use packages

`deploy` To quickly deploy the server (currently just `merope`)

`sops` To manage secrets


## Secrets

For deployment secrets (such as user passwords and server service secrets), I'm
using the awesome [`sops-nix`](https://github.com/Mic92/sops-nix). All secrets
are encrypted with my personal PGP key (stored on a YubiKey), as well as the
relevant systems's SSH host keys.

On my desktop and laptop, I use `pass` for managing passwords, which are
encrypted using (you bet) my PGP key. This same key is also used for mail
signing, as well as for SSH'ing around.

## Tooling and applications I use

Most relevant user apps daily drivers:
- sway + swayidle + swaylock
- waybar
- neovim
- fish + starship
- kitty
- qutebrowser
- neomutt + mbsync
- khal + khard + todoman + vdirsyncer
- gpg + pass
- tailscale
- podman
- zathura
- wofi
- bat + fd + rg
- kdeconnect
- sublime-music

Some of the services I host:
- navidrome
- deluge
- jitsi
- nextcloud
- minecraft
- headscale

Nixy stuff:
- nix-colors
- sops-nix
- impermanence
- home-manager
- deploy-rs
- and NixOS and nix itself, of course :)

Let me know if you have any questions about them :)

## Unixpornish stuff
![screenshot](https://preview.redd.it/q8z05dsvrvb81.png?width=960&crop=smart&auto=webp&s=d66264a468c0ca194cc8cbb2ab80829eea7921a7)

That's how my sway setups (desktop and laptop) look like (as of start of 2022).

If you're interested in my WM configurations, they're managed by home-manager and are located at `home-mnager/desktop/sway`.
