{ pkgs, config, ... }:

let
  colors = import ../../../colors.nix;
  username = "${config.home.username}";
in {
  imports = [
    ../../../modules/colorscheme.nix
    ../../../modules/ethminer.nix
    ../../../modules/wallpaper.nix
    ./alacritty.nix
    ./direnv.nix
    ./discord.nix
    ./ethminer.nix
    ./fira.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./gpg.nix
    ./gtk.nix
    ./kdeconnect.nix
    ./lutris.nix
    ./mako.nix
    ./multimc.nix
    ./neofetch.nix
    ./nix-index.nix
    ./nvim.nix
    ./osu.nix
    ./pass.nix
    ./qt.nix
    ./qutebrowser.nix
    ./rgbdaemon.nix
    ./runescape.nix
    ./starship.nix
    ./steam.nix
    ./sway.nix
    ./swaylock.nix
    ./waybar.nix
    ./zathura.nix
  ];

  colorscheme = colors.${import ./current-scheme.nix};
  wallpaper.path = "/home/misterio/Pictures/Wallpapers/blue-red-sky-clouds.jpg";
  # wallpaper.generate = true;

  home.packages = with pkgs; [
    bottom
    cachix
    dragon-drop
    exa
    firefox
    imv
    jq
    lm_sensors
    ncdu
    pavucontrol
    ranger
    setscheme
    spotify
    trash-cli
    vulkan-tools
    xdg-utils
  ];

  home.persistence."/data/home/misterio" = {
    directories = [
      "Documents"
      "Downloads"
      "Pictures"
    ];
    allowOther = false;
  };
}
