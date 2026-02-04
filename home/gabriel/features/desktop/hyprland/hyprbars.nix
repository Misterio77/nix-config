{
  config,
  pkgs,
  lib,
  ...
}: let
  rgb = color: "rgb(${lib.removePrefix "#" color})";
  rgba = color: alpha: "rgba(${lib.removePrefix "#" color}${alpha})";

  hyprbars = pkgs.hyprbars.override {
    # Make sure it's using the same hyprland package as we are
    hyprland = config.wayland.windowManager.hyprland.package;
  };
in {
  wayland.windowManager.hyprland = {
    plugins = [hyprbars];
    settings = {
      plugin.hyprbars = {
        # Local colors
        bar_color = rgba config.colorscheme.colors.surface "dd";
        "col.text" = rgb config.colorscheme.colors.primary;
        bar_height = 25;
        bar_text_font = config.fontProfiles.regular.name;
        bar_text_size = config.fontProfiles.regular.size;
        bar_part_of_window = false;
        bar_precedence_over_border = false;
        hyprbars-button = let
          closeAction = "hyprctl dispatch killactive";

          isOnSpecial = ''hyprctl activewindow -j | jq -re 'select(.workspace.name == "special")' >/dev/null'';
          moveToSpecial = "hyprctl dispatch movetoworkspacesilent special";
          moveToActive = "hyprctl dispatch movetoworkspacesilent $(hyprctl -j activeworkspace | jq -re '.id')";
          minimizeAction = "${isOnSpecial} && ${moveToActive} || ${moveToSpecial}";

          maximizeAction = "hyprctl dispatch fullscreen 1";
        in [
          # Red close button
          "${rgb config.colorscheme.colors.red},12,,${closeAction}"
          # Yellow "minimize" (send to special workspace) button
          "${rgb config.colorscheme.colors.yellow},12,,${minimizeAction}"
          # Green "maximize" (fullscreen) button
          "${rgb config.colorscheme.colors.green},12,,${maximizeAction}"
        ];
      };

      windowrule = [
        # Disable bars in floating pinned windows
        "hyprbars:no_bar on, match:float 1, match:pin 1"

        # Local colors (this host's colors)
        "hyprbars:bar_color ${rgba config.colorscheme.colors.surface "dd"}, match:focus 0"
        "hyprbars:title_color ${rgb config.colorscheme.colors.primary}, match:focus 0"
        # Local focused colors
        "hyprbars:bar_color ${rgba config.colorscheme.colors.primary "ee"}, match:focus 1"
        "hyprbars:title_color ${rgb config.colorscheme.colors.on_primary}, match:focus 1"
      ] ++ (lib.flatten (lib.mapAttrsToList (name: colors: [
        # Remote host colors
        "hyprbars:bar_color ${rgba colors.primary_container "dd"}, match:title \\[${name}\\].*, match:focus 0"
        "hyprbars:title_color ${rgb colors.on_primary_container}, match:title \\[${name}\\].*, match:focus 0"

        # Remote host focused colors
        "hyprbars:bar_color ${rgba colors.primary "ee"}, match:title \\[${name}\\].*, match:focus 1"
        "hyprbars:title_color ${rgb colors.on_primary}, match:title \\[${name}\\].*, match:focus 1"
      ]) config.colorscheme.hosts));
    };
  };
}
