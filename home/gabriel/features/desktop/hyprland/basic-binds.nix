{lib, config, ...}: {
  wayland.windowManager.hyprland.settings = {
    bindm = [
      "SUPER,mouse:272,movewindow"
      "SUPER,mouse:273,resizewindow"
    ];

    bind = let
      workspaces = [
        "0"
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
      ];
      # Map keys (arrows and hjkl) to hyprland directions (l, r, u, d)
      directions = rec {
        left = "l";
        right = "r";
        up = "u";
        down = "d";
        h = left;
        l = right;
        k = up;
        j = down;
      };
    in
      [
        "SUPERSHIFT,q,killactive"
        "SUPERSHIFT,e,exit"

        "SUPER,s,togglesplit"
        "SUPER,f,fullscreen,1"
        "SUPERSHIFT,f,fullscreen,0"
        "SUPERSHIFT,space,togglefloating"

        "SUPER,minus,splitratio,-0.25"
        "SUPERSHIFT,minus,splitratio,-0.3333333"

        "SUPER,equal,splitratio,0.25"
        "SUPERSHIFT,equal,splitratio,0.3333333"

        "SUPER,g,togglegroup"
        "SUPER,t,lockactivegroup,toggle"
        "SUPER,tab,changegroupactive,f"
        "SUPERSHIFT,tab,changegroupactive,b"

        "SUPER,apostrophe,workspace,previous"
        "SUPERSHIFT,apostrophe,workspace,next"
        "SUPER,dead_grave,workspace,previous"
        "SUPERSHIFT,dead_grave,workspace,next"

        "SUPER,u,togglespecialworkspace"
        "SUPERSHIFT,u,movetoworkspacesilent,special"
        "SUPER,y,toggleswallow"
        "SUPER,i,pin"
      ]
      ++
      # Change workspace
      (map (n: "SUPER,${n},workspace,${n}") workspaces)
      ++
      # Move window to workspace
      (map (n: "SUPERSHIFT,${n},movetoworkspacesilent,${n}") workspaces)
      ++
      # Move focus
      (lib.mapAttrsToList (key: direction: "SUPER,${key},movefocus,${direction}") directions)
      ++
      # Swap windows
      (lib.mapAttrsToList (key: direction: "SUPERSHIFT,${key},swapwindow,${direction}") directions)
      ++
      # Move windows
      (lib.mapAttrsToList (
          key: direction: "SUPERCONTROL,${key},movewindow,${direction}"
        )
        directions)
      ++
      # Move monitor focus
      (lib.mapAttrsToList (key: direction: "SUPERALT,${key},focusmonitor,${direction}") directions)
      ++
      # Move workspace to other monitor
      (lib.mapAttrsToList (
          key: direction: "SUPERALTSHIFT,${key},movecurrentworkspacetomonitor,${direction}"
        )
        directions);
  };
}
