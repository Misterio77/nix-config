{ pkgs, hostname, lib, outputs, ... }:
let
  systemConfig = outputs.nixosConfigurations.${hostname}.config;
in
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
  ] ++ (lib.optional systemConfig.networking.wireless.enable ./wpa-gui.nix);

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    xdg-utils-spawn-terminal
  ];
}
