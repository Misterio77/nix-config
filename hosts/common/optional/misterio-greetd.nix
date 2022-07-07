{ pkgs, ... }:
let
  user = "misterio";
  cage = "${pkgs.cage}/bin/cage";
  greetd = "${pkgs.greetd.greetd}/bin/greetd";
  gtkgreet = "${pkgs.greetd.gtkgreet}/bin/gtkgreet";
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        inherit user;
        command = "${cage} -- ${gtkgreet} -c '$SHELL -l' -l";
      };
      initial_session = {
        inherit user;
        command = "$SHELL -l";
      };
    };
  };
}
