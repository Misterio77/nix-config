{ config, pkgs, lib, ... }: let
  hyprbars = (pkgs.inputs.hyprland-plugins.hyprbars.override {
    # Make sure it's using the same hyprland package as we are
    hyprland = config.wayland.windowManager.hyprland.package;
  }).overrideAttrs (old: {
    # Yeet the initialization notification (I hate it)
    postPatch = (old.postPatch or "") + ''
      ${lib.getExe pkgs.gnused} -i '/Initialized successfully/d' main.cpp
    '';
  });
in {
  wayland.windowManager.hyprland = {
    plugins = [ hyprbars ];
    settings = {
      "plugin:hyprbars" = {
        bar_height = 25;
        bar_color = "0xee${config.colorscheme.colors.base01}";
        "col.text" = "0xee${config.colorscheme.colors.base05}";
        bar_text_font = config.fontProfiles.regular.family;
        bar_text_size = 12;
        hyprbars-button = let
          closeAction = "hyprctl dispatch killactive";

          isOnSpecial = ''hyprctl activewindow -j | jq -re 'select(.workspace.name == "special")' >/dev/null'';
          moveToSpecial = "hyprctl dispatch movetoworkspacesilent special";
          moveToActive = "hyprctl dispatch movetoworkspacesilent name:$(hyprctl -j activeworkspace | jq -re '.name')";
          minimizeAction = "${isOnSpecial} && ${moveToActive} || ${moveToSpecial}";

          maximizeAction = "hyprctl dispatch fullscreen 1";
        in [
          # Red close button
          "rgb(${config.colorscheme.colors.base08}),12,,${closeAction}"
          # Yellow "minimize" (send to special workspace) button
          "rgb(${config.colorscheme.colors.base0A}),12,,${minimizeAction}"
          # Green "maximize" (fullscreen) button
          "rgb(${config.colorscheme.colors.base0B}),12,,${maximizeAction}"
        ];
      };
      bind = let
        barsEnabled = "hyprctl -j getoption plugin:hyprbars:bar_height | ${lib.getExe pkgs.jq} -re '.int != 0'";
        setBarHeight = height: "hyprctl keyword plugin:hyprbars:bar_height ${toString height}";
        toggleOn = setBarHeight config.wayland.windowManager.hyprland.settings."plugin:hyprbars".bar_height;
        toggleOff = setBarHeight 0;
      in [
        "SUPER,m,exec,${barsEnabled} && ${toggleOff} || ${toggleOn}"
      ];
    };
  };
}
