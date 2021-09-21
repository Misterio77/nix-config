{ pkgs, config, ... }:

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
    ./firefox.nix
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

  colorscheme = colors.${import ./current-scheme.nix};
  # wallpaper.path = "/home/misterio/Pictures/Wallpapers/cyberpunk-city.jpg";
  wallpaper.generate = true;

  home.packages = with pkgs; [
    # Cli
    bottom
    cachix
    dragon-drop
    exa
    imv
    ncdu
    ranger
    setscheme
    trash-cli
    xdg-utils
    ydotool

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
