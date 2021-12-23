{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./discord.nix
    ./fira.nix
    ./firefox.nix
    ./gtk.nix
    ./kdeconnect.nix
    ./mako.nix
    ./qt.nix
    ./qutebrowser.nix
    ./sway.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./zathura.nix
  ];

  xdg.mimeApps.enable = true;

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
