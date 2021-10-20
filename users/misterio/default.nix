{ pkgs, hostname, impermanence, nix-colors, nur, ... }:

{
  imports = [
    impermanence.nixosModules.home-manager.impermanence
    ./direnv.nix
    ./fish.nix
    ./git.nix
    ./neofetch.nix
    ./nix-index.nix
    ./nvim.nix
    ./starship.nix
  ] ++ (if hostname == "atlas" then [
    nix-colors.homeManagerModule
    ./rice.nix

    ./discord.nix
    ./element.nix
    ./ethminer.nix
    ./fira.nix
    ./gpg.nix
    ./gtk.nix
    ./kdeconnect.nix
    ./kitty.nix
    ./lutris.nix
    ./mail.nix
    ./mako.nix
    ./multimc.nix
    ./neomutt.nix
    ./obs.nix
    ./osu.nix
    ./pass.nix
    ./qt.nix
    ./qutebrowser.nix
    ./rgbdaemon.nix
    # ./runescape.nix
    ./slack.nix
    ./steam.nix
    ./sway.nix
    ./swayidle.nix
    ./swaylock.nix
    ./yuzu.nix
    ./waybar.nix
    ./zathura.nix
  ] else
    [ ]);

  programs.home-manager.enable = true;

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ nur.overlay ];
  };

  systemd.user.startServices = "sd-switch";

  home.file.bin.source = ./scripts;

  home.packages = with pkgs;
    [
      # Cli
      bottom
      cachix
      pkgs.nur.repos.misterio.comma
      exa
      ncdu
      ranger
      rnix-lsp
    ] ++ (if hostname == "atlas" then [
      setscheme
      setwallpaper
      amdgpu-clocks

      # Gui apps
      dragon-drop
      imv
      pavucontrol
      spotify
      wofi
      xdg-utils
      ydotool
    ] else if hostname == "merope" then [
      pkgs.nur.repos.misterio.argononed
    ] else [ ]);

  home.persistence = {
    "/data/home/misterio" = {
      directories = [ "Documents" "Downloads" "Pictures" "Videos" ];
      allowOther = true;
    };
  };
}
