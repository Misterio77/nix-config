{ pkgs, ... }:
{
  imports = [
    ./discord.nix
    ./element.nix
    ./fira.nix
    ./firefox.nix
    ./gtk.nix
    ./kdeconnect.nix
    ./kitty.nix
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
    waypipe
    dragon-drop
    imv
    pavucontrol
    spotify
    wofi
    xdg-utils
    ydotool
  ];
}
