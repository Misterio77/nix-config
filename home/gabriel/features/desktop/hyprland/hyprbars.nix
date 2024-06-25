{
  config,
  pkgs,
  lib,
  outputs,
  ...
}: let
  getHostname = x: lib.last (lib.splitString "@" x);
  remoteColorschemes = lib.mapAttrs' (n: v: {
    name = getHostname n;
    value = v.config.colorscheme.rawColorscheme.colors.${config.colorscheme.mode};
  }) outputs.homeConfigurations;
  rgb = color: "rgb(${lib.removePrefix "#" color})";
  rgba = color: alpha: "rgba(${lib.removePrefix "#" color}${alpha})";

  hyprbars =
    (pkgs.hyprbars.override {
      # Make sure it's using the same hyprland package as we are
      hyprland = config.wayland.windowManager.hyprland.package;
    })
    .overrideAttrs
    (old: {
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
        bar_height = 25;
        bar_color = rgba config.colorscheme.colors.surface "cc";
        "col.text" = rgb config.colorscheme.colors.primary;
        bar_text_font = config.fontProfiles.regular.family;
        bar_text_size = 12;
        bar_part_of_window = true;
        bar_precedence_over_border = true;
        hyprbars-button = let
          closeAction = "hyprctl dispatch killactive";

          isOnSpecial = ''hyprctl activewindow -j | jq -re 'select(.workspace.name == "special")' >/dev/null'';
          moveToSpecial = "hyprctl dispatch movetoworkspacesilent special";
          moveToActive = "hyprctl dispatch movetoworkspacesilent name:$(hyprctl -j activeworkspace | jq -re '.name')";
          minimizeAction = "${isOnSpecial} && ${moveToActive} || ${moveToSpecial}";

          maximizeAction = "hyprctl dispatch togglefloating";
        in [
          # Red close button
          "${rgb config.colorscheme.harmonized.red},12,,${closeAction}"
          # Yellow "minimize" (send to special workspace) button
          "${rgb config.colorscheme.harmonized.yellow},12,,${minimizeAction}"
          # Green "maximize" (togglefloating) button
          "${rgb config.colorscheme.harmonized.green},12,,${maximizeAction}"
        ];
      };

      windowrulev2 = [
        "plugin:hyprbars:bar_color ${rgba config.colorscheme.colors.primary "bb"}, focus:1"
        "plugin:hyprbars:title_color ${rgb config.colorscheme.colors.surface}, focus:1"
      ] ++ (lib.flatten (lib.mapAttrsToList (name: colors: [
        "plugin:hyprbars:bar_color ${rgba colors.surface "cc"}, title:^(\\[${name}\\])"
        "plugin:hyprbars:title_color ${rgb colors.primary}, title:^(\\[${name}\\])"

        "plugin:hyprbars:bar_color ${rgba colors.primary "bb"}, title:^(\\[${name}\\]), focus:1"
        "plugin:hyprbars:title_color ${rgb colors.surface}, title:^(\\[${name}\\]), focus:1"
      ]) remoteColorschemes));
    };
  };
}
