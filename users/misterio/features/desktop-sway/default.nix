{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./discord.nix
    ./element.nix
    ./fira.nix
    ./firefox.nix
    ./gtk.nix
    ./kdeconnect.nix
    ./mako.nix
    ./obs.nix
    ./qt.nix
    ./qutebrowser.nix
    ./slack.nix
    ./sway.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./zathura.nix
  ];

  home.packages = with pkgs; [
    dragon-drop
    imv
    pavucontrol
    spotify
    wofi
    xdg-utils
    ydotool
  ];
}
