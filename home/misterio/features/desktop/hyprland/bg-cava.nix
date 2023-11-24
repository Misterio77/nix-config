{ config, pkgs, lib, ... }: let
  hyprwinwrap = (pkgs.inputs.hyprland-plugins.hyprwinwrap.override {
    # Make sure it's using the same hyprland package as we are
    hyprland = config.wayland.windowManager.hyprland.package;
  });
  class = "cava-bg";
in {
  wayland.windowManager.hyprland = {
    plugins = [ hyprwinwrap ];
    settings = {
      "plugin:hyprwinwrap" = {
        inherit class;
      };
      exec = [
        "${config.home.sessionVariables.TERMINAL} --class ${class} '${lib.getExe pkgs.cava}'"
      ];
    };
  };
}
