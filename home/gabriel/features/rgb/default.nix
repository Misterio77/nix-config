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
      model = "CORSAIR K70 RGB MK.2 Mechanical Gaming Keyboard";
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
      model = "CORSAIR SCIMITAR RGB ELITE Gaming Mouse";
      dpi = 750;
      highlighted = [
        "wheel"
        "thumb"
      ];
    };
  };
}
