{ pkgs, lib, outputs, ... }:
{
  imports = [
    ./deluge.nix
    ./discord.nix
    ./dragon.nix
    ./firefox.nix
    ./font.nix
    ./gtk.nix
    ./kdeconnect.nix
    ./pavucontrol.nix
    ./playerctl.nix
    ./qt.nix
    ./sublime-music.nix
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    xdg-utils-spawn-terminal
  ];
}
