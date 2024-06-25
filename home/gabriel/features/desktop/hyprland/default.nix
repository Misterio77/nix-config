{
  lib,
  config,
  pkgs,
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
in {
  imports = [
    ../common
    ../common/wayland-wm

    ./basic-binds.nix
    ./hyprbars.nix
  ];

  xdg.portal = let
    hyprland = config.wayland.windowManager.hyprland.package;
    xdph = pkgs.xdg-desktop-portal-hyprland.override {inherit hyprland;};
  in {
    extraPortals = [xdph];
    configPackages = [hyprland];
  };

  home.packages = with pkgs; [
    grimblast
    hyprpicker
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland.override {wrapRuntimeDeps = false;};
    systemd = {
      enable = true;
      # Same as default, but stop graphical-session too
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };

    settings = {
      general = {
        gaps_in = 15;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = rgba config.colorscheme.colors.primary "aa";
        "col.inactive_border" = rgba config.colorscheme.colors.surface_bright "aa";
        # v0.40.0 and earlier
        cursor_inactive_timeout = 4;
      };
      # Later versions
      # cursor.inactive_timeout = 4;
      group = {
        "col.border_active" = rgba config.colorscheme.colors.primary "aa";
        "col.border_inactive" = rgba config.colorscheme.colors.surface_bright "aa";
        groupbar.font_size = 11;
      };
      binds = {
        movefocus_cycles_fullscreen = false;
      };
      input = {
        kb_layout = "br,us";
        touchpad.disable_while_typing = false;
      };
      dwindle = {
        split_width_multiplier = 1.35;
        pseudotile = true;
      };
      misc = {
        vfr = true;
        close_special_on_empty = true;
        focus_on_activate = true;
        # Unfullscreen when opening something
        new_window_takes_over_fullscreen = 2;
      };
      windowrulev2 = let
        sweethome3d-tooltips = "title:^(win[0-9])$,class:^(com-eteks-sweethome3d-SweetHome3DBootstrap)$";
        steam = "title:^()$,class:^(steam)$";
        kdeconnect-pointer = "class:^(kdeconnect.daemon)$";
      in [
        "nofocus, ${sweethome3d-tooltips}"

        "stayfocused, ${steam}"
        "minsize 1 1, ${steam}"

        "size 100% 110%, ${kdeconnect-pointer}"
        "center, ${kdeconnect-pointer}"
        "nofocus, ${kdeconnect-pointer}"
        "noblur, ${kdeconnect-pointer}"
        "noanim, ${kdeconnect-pointer}"
        "noshadow, ${kdeconnect-pointer}"
        "noborder, ${kdeconnect-pointer}"
        "suppressevent fullscreen, ${kdeconnect-pointer}"
      ] ++ (lib.mapAttrsToList (name: colors:
        "bordercolor ${rgba colors.primary "aa"} ${rgba colors.surface_bright "aa"}, title:^(\\[${name}\\])"
      ) remoteColorschemes);
      layerrule = [
        "animation fade,hyprpicker"
        "animation fade,selection"

        "animation fade,waybar"
        "blur,waybar"
        "ignorezero,waybar"

        "blur,notifications"
        "ignorezero,notifications"

        "blur,wofi"
        "ignorezero,wofi"

        "noanim,wallpaper"
      ];

      decoration = {
        active_opacity = 1.0;
        inactive_opacity = 0.85;
        fullscreen_opacity = 1.0;
        rounding = 7;
        blur = {
          enabled = true;
          size = 4;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
          popups = true;
        };
        drop_shadow = true;
        shadow_range = 12;
        shadow_offset = "3 3";
        "col.shadow" = "0x44000000";
        "col.shadow_inactive" = "0x66000000";
      };
      animations = {
        enabled = true;
        bezier = [
          "easein,0.1, 0, 0.5, 0"
          "easeinback,0.35, 0, 0.95, -0.3"

          "easeout,0.5, 1, 0.9, 1"
          "easeoutback,0.35, 1.35, 0.65, 1"

          "easeinout,0.45, 0, 0.55, 1"
        ];

        animation = [
          "fadeIn,1,3,easeout"
          "fadeLayersIn,1,3,easeoutback"
          "layersIn,1,3,easeoutback,slide"
          "windowsIn,1,3,easeoutback,slide"

          "fadeLayersOut,1,3,easeinback"
          "fadeOut,1,3,easein"
          "layersOut,1,3,easeinback,slide"
          "windowsOut,1,3,easeinback,slide"

          "border,1,3,easeout"
          "fadeDim,1,3,easeinout"
          "fadeShadow,1,3,easeinout"
          "fadeSwitch,1,3,easeinout"
          "windowsMove,1,3,easeoutback"
          "workspaces,1,2.6,easeoutback,slide"
        ];
      };

      exec = ["${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill"];

      bind = let
        grimblast = lib.getExe pkgs.grimblast;
        tesseract = lib.getExe pkgs.tesseract;
        pactl = lib.getExe' pkgs.pulseaudio "pactl";
        notify-send = lib.getExe' pkgs.libnotify "notify-send";
        defaultApp = type: "${lib.getExe pkgs.handlr-regex} launch ${type}";
        remote = lib.getExe (pkgs.writeShellScriptBin "remote" ''
          socket="$(basename "$(find ~/.ssh -name 'master-*' | head -1 | cut -d ':' -f1)")"
          host="''${socket#master-}"
          ssh "$host" "$@"
        '');
      in
        [
          # Program bindings
          "SUPER,Return,exec,${defaultApp "x-scheme-handler/terminal"}"
          "SUPER,e,exec,${defaultApp "text/plain"}"
          "SUPER,b,exec,${defaultApp "x-scheme-handler/https"}"
          "SUPERALT,Return,exec,${remote} ${defaultApp "x-scheme-handler/terminal"}"
          "SUPERALT,e,exec,${remote} ${defaultApp "text/plain"}"
          "SUPERALT,b,exec,${remote} ${defaultApp "x-scheme-handler/https"}"
          # Brightness control (only works if the system has lightd)
          ",XF86MonBrightnessUp,exec,light -A 10"
          ",XF86MonBrightnessDown,exec,light -U 10"
          # Volume
          ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
          ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
          ",XF86AudioMute,exec,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
          "SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
          ",XF86AudioMicMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
          # Screenshotting
          ",Print,exec,${grimblast} --notify --freeze copy output"
          "SUPER,Print,exec,${grimblast} --notify --freeze copy area"
          # To OCR
          "ALT,Print,exec,${grimblast} --freeze save area - | ${tesseract} - - | wl-copy && ${notify-send} -t 3000 'OCR result copied to buffer'"
        ]
        ++ (
          let
            playerctl = lib.getExe' config.services.playerctld.package "playerctl";
            playerctld = lib.getExe' config.services.playerctld.package "playerctld";
          in
            lib.optionals config.services.playerctld.enable [
              # Media control
              ",XF86AudioNext,exec,${playerctl} next"
              ",XF86AudioPrev,exec,${playerctl} previous"
              ",XF86AudioPlay,exec,${playerctl} play-pause"
              ",XF86AudioStop,exec,${playerctl} stop"
              "ALT,XF86AudioNext,exec,${playerctld} shift"
              "ALT,XF86AudioPrev,exec,${playerctld} unshift"
              "ALT,XF86AudioPlay,exec,systemctl --user restart playerctld"
            ]
        )
        ++
        # Screen lock
        (
          let
            swaylock = lib.getExe config.programs.swaylock.package;
          in
            lib.optionals config.programs.swaylock.enable [
              ",XF86Launch5,exec,${swaylock} -S --grace 2"
              ",XF86Launch4,exec,${swaylock} -S --grace 2"
              "SUPER,backspace,exec,${swaylock} -S --grace 2"
            ]
        )
        ++
        # Notification manager
        (
          let
            makoctl = lib.getExe' config.services.mako.package "makoctl";
          in
            lib.optionals config.services.mako.enable [
              "SUPER,w,exec,${makoctl} dismiss"
              "SUPERSHIFT,w,exec,${makoctl} restore"
            ]
        )
        ++
        # Launcher
        (
          let
            wofi = lib.getExe config.programs.wofi.package;
          in
            lib.optionals config.programs.wofi.enable [
              "SUPER,x,exec,${wofi} -S drun -x 10 -y 10 -W 25% -H 60%"
              "SUPER,s,exec,specialisation $(specialisation | ${wofi} -S dmenu)"
              "SUPER,d,exec,${wofi} -S run"

              "SUPERALT,x,exec,${remote} ${wofi} -S drun -x 10 -y 10 -W 25% -H 60%"
              "SUPERALT,d,exec,${remote} ${wofi} -S run"
            ]
            ++ (
              let
                pass-wofi = lib.getExe (pkgs.pass-wofi.override {pass = config.programs.password-store.package;});
              in
                lib.optionals config.programs.password-store.enable [
                  ",Scroll_Lock,exec,${pass-wofi}" # fn+k
                  ",XF86Calculator,exec,${pass-wofi}" # fn+f12
                  "SUPER,semicolon,exec,${pass-wofi}"
                  "SHIFT,Scroll_Lock,exec,${pass-wofi} fill" # fn+k
                  "SHIFT,XF86Calculator,exec,${pass-wofi} fill" # fn+f12
                  "SHIFTSUPER,semicolon,exec,${pass-wofi} fill"
                ]
            ) ++ (
              let
                cliphist = lib.getExe config.services.cliphist.package;
              in
              lib.optionals config.services.cliphist.enable [
                ''SUPER,c,exec,selected=$(${cliphist} list | ${wofi} -S dmenu) && echo "$selected" | ${cliphist} decode | wl-copy''
              ]
            )
        );

      monitor = let
        waybarSpace = let
          inherit (config.wayland.windowManager.hyprland.settings.general) gaps_in gaps_out;
          inherit (config.programs.waybar.settings.primary) position height width;
          gap = gaps_out - gaps_in;
        in {
          top = if (position == "top") then height + gap else 0;
          bottom = if (position == "bottom") then height + gap else 0;
          left = if (position == "left") then width + gap else 0;
          right = if (position == "right") then width + gap else 0;
        };
      in
        [
          ",addreserved,${toString waybarSpace.top},${toString waybarSpace.bottom},${toString waybarSpace.left},${toString waybarSpace.right}"
        ]
        ++ (map (
          m: "${m.name},${
            if m.enabled
            then "${toString m.width}x${toString m.height}@${toString m.refreshRate},${toString m.x}x${toString m.y},1"
            else "disable"
          }"
        ) (config.monitors));

      workspace = map (m: "name:${m.workspace},monitor:${m.name}") (
        lib.filter (m: m.enabled && m.workspace != null) config.monitors
      );
    };
    # This is order sensitive, so it has to come here.
    extraConfig = ''
      # Passthrough mode (e.g. for VNC)
      bind=SUPER,P,submap,passthrough
      submap=passthrough
      bind=SUPER,P,submap,reset
      submap=reset
    '';
  };
}
