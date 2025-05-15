{config, lib, ...}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      auth.fingerprint.enabled = true;
      animations = {
        enabled = true;
        bezier = "linear, 1, 1, 0, 0";
        animation = [
          "fade, 1, 2, linear"
          "inputField, 1, 1, linear"
        ];
      };
      background = {
        path = "screenshot";
        blur_passes = 4;
      };
      input-field = {
        font_color = "rgb(${lib.removePrefix "#" config.colorscheme.colors.on_surface})";
        font_family = config.fontProfiles.regular.name;

        position = "0, 20%";
        halign = "center";
        valign = "bottom";

        # Hide outline and filling
        outline_thickness = 0;
        inner_color = "rgba(00000000)";
        check_color = "rgba(00000000)";
        fail_color = "rgba(00000000)";
      };
      label = {
        text = "$TIME";
        color = "rgb(${lib.removePrefix "#" config.colorscheme.colors.on_surface})";
        font_family = config.fontProfiles.regular.name;
        font_size = "180";

        position = "0 0";
        halign = "center";
        valign = "center";
      };
    };
  };
}
