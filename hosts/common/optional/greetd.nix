{ pkgs, ... }:
let
  greetd = "${pkgs.greetd.greetd}/bin/greetd";
  gtkgreet = "${pkgs.greetd.gtkgreet}/bin/gtkgreet";

  sway-kiosk = command: "${pkgs.sway}/bin/sway --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    exec "${command}; ${pkgs.sway}/bin/swaymsg exit"
  ''}";
in
{

  environment.etc."greetd/environments".text ="$SHELL -l";

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = sway-kiosk "${gtkgreet} -l &>/dev/null";
      };
    };
  };
}
