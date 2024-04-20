{config, lib, ...}: let
  inherit (config.colorscheme) colors;
in {
  services.rgbdaemon = {
    enable = true;
    daemons = {
      swayLock = true;
      mute = true;
      player = true;
    };
    colors = {
      background = "${lib.removePrefix "#" colors.surface}";
      foreground = "${lib.removePrefix "#" colors.primary}";
      secondary = "${lib.removePrefix "#" colors.secondary}";
      tertiary = "${lib.removePrefix "#" colors.tertiary}";
      quaternary = "${lib.removePrefix "#" colors.on_surface}";
    };
    keyboard = {
      device = "/dev/input/ckb1/cmd";
      highlighted = [
        "h"
        "j"
        "k"
        "l"
        "w"
        "a"
        "s"
        "d"
        "m3"
        "g11"
        "profswitch"
        "lwin"
        "rwin"
      ];
    };
    mouse = {
      device = "/dev/input/ckb2/cmd";
      dpi = 750;
      highlighted = [
        "wheel"
        "thumb"
      ];
    };
  };
}
