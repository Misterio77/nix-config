{ pkgs, config, host, ... }:

let
  colors = import ../../../colors.nix;
in {
  imports = [
    ./direnv.nix
    ./fish.nix
    ./git.nix
    ./neofetch.nix
    ./nix-index.nix
    ./nvim.nix
    ./starship.nix
  ] ++ (if host == "atlas" then [
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
    ./waybar.nix
    ./zathura.nix
  ] else [ ]);

  colorscheme = colors."${import ./current-scheme.nix}";
  wallpaper.generate = true;

  home.packages = with pkgs; [
    # Cli
    bottom
    cachix
    exa
    ncdu
    ranger
    trash-cli

  ] ++ (if host == "atlas" then [
    # Gui apps
    dragon-drop
    ydotool
    xdg-utils
    setscheme
    imv
    pavucontrol
    spotify
    wofi
  ] else [ ]);

  home.persistence = {
    "/data/home/misterio" = {
      directories = [ "Documents" "Downloads" "Pictures" ];
      allowOther = true;
    };
  };
}
