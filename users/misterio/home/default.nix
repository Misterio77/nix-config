{ pkgs, config, host, ... }:

let
  colors = import ../../../colors.nix;
  username = "${config.home.username}";
in {
  imports = [
    ../../../modules/colorscheme.nix
    ../../../modules/ethminer.nix
    ../../../modules/wallpaper.nix
    ./kitty.nix
    ./direnv.nix
    ./discord.nix
    ./ethminer.nix
    ./element.nix
    ./fira.nix
    ./fish.nix
    ./git.nix
    ./gpg.nix
    ./gtk.nix
    ./kdeconnect.nix
    ./lutris.nix
    ./mail.nix
    ./mako.nix
    ./multimc.nix
    ./neofetch.nix
    ./neomutt.nix
    ./nix-index.nix
    ./nvim.nix
    ./osu.nix
    ./pass.nix
    ./qt.nix
    ./qutebrowser.nix
    ./rgbdaemon.nix
    ./runescape.nix
    ./slack.nix
    ./starship.nix
    ./steam.nix
    ./sway.nix
    ./swaylock.nix
    ./swayidle.nix
    ./waybar.nix
    ./zathura.nix
  ];

  colorscheme = colors."${import ./current-scheme.nix}";
  wallpaper.generate = true;

  home.packages = with pkgs; [
    # Cli
    bottom
    dragon-drop
    exa
    ncdu
    ranger
    trash-cli

    ydotool
    xdg-utils
    setscheme
    imv
    transmission-gtk
    pavucontrol
    spotify
    wofi
  ];

  home.persistence = {
    "/data/home/misterio" = {
      directories = [ "Documents" "Downloads" "Pictures" ];
      allowOther = true;
    };
    "/data/games/misterio" = { allowOther = true; };
  };
}
