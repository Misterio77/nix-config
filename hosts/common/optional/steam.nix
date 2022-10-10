{ pkgs, ... }:
let
  sway-kiosk = command: "${pkgs.sway}/bin/sway --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    exec "${command}; ${pkgs.sway}/bin/swaymsg exit"
  ''}";

  steam-bigpicture = pkgs.writeShellScriptBin "steam-bigpicture" ''
    ${sway-kiosk "${pkgs.steam}/bin/steam -bigpicture"}
  '';
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
  environment.systemPackages = [ steam-bigpicture ];

  hardware.steam-hardware.enable = true;
}
