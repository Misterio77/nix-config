{config, lib, ...}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      auth.fingerprint.enabled = true;
      general = {
        hide_cursor = true;
      };
      animations = {
        enabled = true;
        bezier = [
          "easeout,0.5, 1, 0.9, 1"
          "easeoutback,0.34,1.22,0.65,1"
        ];
        animation = [
          "fade, 1, 3, easeout"
          "inputField, 1, 1, easeoutback"
        ];
      };
      background = {
        path = "screenshot";
        blur_passes = 4;
      };
      input-field = lib.forEach config.monitors (monitor: {
        monitor = monitor.name;
        dots_size = toString (0.15 * monitor.scale);

        font_color = "rgb(${lib.removePrefix "#" config.colorscheme.colors.on_surface})";
        font_family = config.fontProfiles.regular.name;
        position = "0, -20%";
        # $FAIL is moves to another label
        fail_text = "";
        # Hide outline and filling
        outline_thickness = 0;
        inner_color = "rgba(00000000)";
        check_color = "rgba(00000000)";
        fail_color = "rgba(00000000)";
      });
      label = lib.flatten (lib.forEach config.monitors (monitor: [
        {
          monitor = monitor.name;
          text = "$TIME";
          color = "rgb(${lib.removePrefix "#" config.colorscheme.colors.on_surface})";
          font_family = config.fontProfiles.regular.name;
          font_size = toString (140 * monitor.scale);
          position = "0 0";
        }
        {
          monitor = monitor.name;
          text = "$FAIL";
          font_color = "rgb(${lib.removePrefix "#" config.colorscheme.colors.on_surface})";
          font_family = config.fontProfiles.regular.name;
          font_size = toString (18 * monitor.scale);
          position = "0, -40%";
        }
      ]));
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      bind = let
        hyprlock = lib.getExe config.programs.hyprlock.package;
      in [
        "SUPER,backspace,exec,${hyprlock}"
        "SUPER,XF86Calculator,exec,${hyprlock}"
      ];
    };
  };
}
