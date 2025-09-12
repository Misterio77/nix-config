{
  config,
  pkgs,
  lib,
  ...
}: let
  rgb = color: "rgb(${lib.removePrefix "#" color})";
  rgba = color: alpha: "rgba(${lib.removePrefix "#" color}${alpha})";

  hyprbars =
    (pkgs.hyprlandPlugins.hyprbars.override {
      # Make sure it's using the same hyprland package as we are
      hyprland = config.wayland.windowManager.hyprland.package;
    })
    .overrideAttrs
    (old: {
      # Update to 0.51.0
      src = "${pkgs.fetchFromGitHub {
        owner = "hyprwm";
        repo = "hyprland-plugins";
        rev = "376d08bbbd861f2125f5ef86e0003e3636ce110f";
        hash = "sha256-MeRYPD6GTbBEcoEqwl8kqCSKtM8CJcYayvPfKGoQkzc=";
      }}/hyprbars";
      # Yeet the initialization notification (I hate it)
      postPatch =
        (old.postPatch or "")
        + ''
          ${lib.getExe pkgs.gnused} -i '/Initialized successfully/d' main.cpp
        '';
    });
in {
  wayland.windowManager.hyprland = {
    plugins = [hyprbars];
    settings = {
      "plugin:hyprbars" = {
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

      windowrulev2 = [
        # Disable bars in floating pinned windows
        "plugin:hyprbars:nobar, floating:1, pinned:1"

        # Local focused colors (this host's colors)
        "plugin:hyprbars:bar_color ${rgba config.colorscheme.colors.primary "ee"}, focus:1"
        "plugin:hyprbars:title_color ${rgb config.colorscheme.colors.on_primary}, focus:1"
      ] ++ (lib.flatten (lib.mapAttrsToList (name: colors: [
        # Remote host colors
        "plugin:hyprbars:bar_color ${rgba colors.primary_container "dd"}, title:\\[${name}\\].*"
        "plugin:hyprbars:title_color ${rgb colors.on_primary_container}, title:\\[${name}\\].*"

        # Remote host focused colors
        "plugin:hyprbars:bar_color ${rgba colors.primary "ee"}, title:\\[${name}\\].*, focus:1"
        "plugin:hyprbars:title_color ${rgb colors.on_primary}, title:\\[${name}\\].*, focus:1"
      ]) config.colorscheme.hosts));
    };
  };
}
