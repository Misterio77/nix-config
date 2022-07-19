{ pkgs, lib, config, outputs, hostname, ... }:
let
  user = "misterio";
  cage = "${pkgs.cage}/bin/cage";
  greetd = "${pkgs.greetd.greetd}/bin/greetd";
  gtkgreet = "${pkgs.greetd.gtkgreet}/bin/gtkgreet";

  homeConfig = outputs.homeConfigurations."misterio@${hostname}".config;

  hasSteam = config.programs.steam.enable;
  hasSway = homeConfig.wayland.windowManager.sway.enable;
  hasHyprland = homeConfig.wayland.windowManager.hyprland.enable;

  sway-kiosk = command: "${pkgs.sway}/bin/sway --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    exec "${command}; ${pkgs.sway}/bin/swaymsg exit"
  ''}";

  steam-bigpicture = pkgs.writeShellScriptBin "steam-bigpicture" ''
    ${sway-kiosk "${pkgs.steam}/bin/steam -bigpicture"}
  '';
in
{
  environment.systemPackages = lib.mkIf hasSteam [ steam-bigpicture ];

  environment.etc."greetd/environments".text =
    lib.optionalString hasHyprland "Hyprland\n" +
    lib.optionalString hasSway "sway\n" +
    "$SHELL\n" +
    lib.optionalString hasSteam "steam-bigpicture\n";

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        inherit user;
        command = sway-kiosk "${gtkgreet} -l &>/dev/null";
      };
      initial_session = {
        inherit user;
        command =
          if hasHyprland then "Hyprland"
          else if  hasSway then "sway"
          else "$SHELL -l";
      };
    };
  };
}
