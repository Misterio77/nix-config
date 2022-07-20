{ lib, pkgs, config, ... }: {
  imports = [
    ../common
    ../common/wayland-wm
  ];

  wayland.windowManager.sway =
    let
      inherit (config.colorscheme) colors;
      inherit (config.home.preferredApps) menu browser editor mail notifier terminal;

      modifier = "Mod4";
    in
    {
      enable = true;
      wrapperFeatures.gtk = true;
      config = {
        inherit modifier;
        terminal = "${terminal.cmd}";
        menu = "${menu.run-cmd}";
        fonts = {
          names = [ config.fontProfiles.regular.family ];
          size = 12.0;
        };
        output = {
          eDP-1 = {
            res = "1920x1080@60hz";
            pos = "0 15";
            bg = "${config.wallpaper} fill";
          };
          DP-3 = {
            res = "1920x1080@60hz";
            pos = "0 0";
            bg = "${config.wallpaper} fill";
          };
          DP-1 = {
            res = "2560x1080@75hz";
            pos = "1920 65";
            bg = "${config.wallpaper} fill";
          };
          DP-2 = {
            res = "1920x1080@60hz";
            pos = "4480 0";
            bg = "${config.wallpaper} fill";
          };
        };
        defaultWorkspace = "workspace number 1";
        input = {
          # Keyboards
          "6940:6985:Corsair_CORSAIR_K70_RGB_MK.2_Mechanical_Gaming_Keyboard" = {
            xkb_layout = "br";
          };
          "6940:6985:ckb1:_CORSAIR_K70_RGB_MK.2_Mechanical_Gaming_Keyboard_vKB" = {
            xkb_layout = "br";
          };
          "1:1:AT_Translated_Set_2_keyboard" = {
            xkb_layout = "br";
          };
          # Mouses
          "6940:7051:ckb2:_CORSAIR_SCIMITAR_RGB_ELITE_Gaming_Mouse_vM" = {
            pointer_accel = "1";
          };
          "1739:52781:MSFT0001:00_06CB:CE2D_Touchpad" = {
            tap = "enabled";
            dwt = "disabled";
          };
        };
        gaps = {
          horizontal = 5;
          inner = 28;
        };
        floating.criteria = [
          { app_id = "zenity"; }
          { class = "net-runelite-launcher-Launcher"; }
        ];
        colors = {
          focused = {
            border = "${colors.base0C}";
            background = "${colors.base00}";
            text = "${colors.base05}";
            indicator = "${colors.base09}";
            childBorder = "${colors.base0C}";
          };
          focusedInactive = {
            border = "${colors.base03}";
            background = "${colors.base00}";
            text = "${colors.base04}";
            indicator = "${colors.base03}";
            childBorder = "${colors.base03}";
          };
          unfocused = {
            border = "${colors.base02}";
            background = "${colors.base00}";
            text = "${colors.base03}";
            indicator = "${colors.base02}";
            childBorder = "${colors.base02}";
          };
          urgent = {
            border = "${colors.base09}";
            background = "${colors.base00}";
            text = "${colors.base03}";
            indicator = "${colors.base09}";
            childBorder = "${colors.base09}";
          };
        };
        startup = [
          # Initial lock
          { command = "${pkgs.swaylock-effects}/bin/swaylock -i ${config.wallpaper}"; }
          # Start idle daemon
          { command = "${pkgs.swayidle}/bin/swayidle -w"; }
          # Add transparency
          { command = "SWAYFADER_CON_INAC=0.85 ${pkgs.swayfader}/bin/swayfader"; }
          # Set biggest monitor as xwayland primary
          { command = "${pkgs.primary-xwayland}/bin/primary-xwayland largest"; }
          # https://github.com/NixOS/nixpkgs/issues/119445
          { command = "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK"; }
        ];
        bars = [{
          command = "waybar";
        }];
        window = {
          border = 2;
          commands = [
            {
              command = "move scratchpad";
              criteria = { title = "Wine System Tray"; };
            }
            {
              command = "move scratchpad";
              criteria = { title = "Firefox — Sharing Indicator"; };
            }
          ];
        };
        keybindings = lib.mkOptionDefault
          {
            # Focus parent or child
            "${modifier}+bracketleft" = "focus parent";
            "${modifier}+bracketright" = "focus child";

            # Layout types
            "${modifier}+s" = "layout stacking";
            "${modifier}+t" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";

            # Splits
            "${modifier}+minus" = "split v";
            "${modifier}+backslash" = "split h";

            # Scratchpad
            "${modifier}+u" = "scratchpad show";
            "${modifier}+Shift+u" = "move scratchpad";

            # Move entire workspace
            "${modifier}+Mod1+h" = "move workspace to output left";
            "${modifier}+Mod1+Left" = "move workspace to output left";
            "${modifier}+Mod1+l" = "move workspace to output right";
            "${modifier}+Mod1+Right" = "move workspace to output right";

            # Toggle monitors
            "${modifier}+Control+Left" = "output DP-3 toggle";
            "${modifier}+Control+Down" = "output DP-1 toggle";
            "${modifier}+Control+Right" = "output DP-2 toggle";

            # Lock screen
            "XF86Launch5" = "exec swaylock -S"; # lock icon on k70
            "XF86Launch4" = "exec swaylock -S"; # fn+q

            # Volume
            "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "Shift+XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";

            # Brightness
            "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 10";
            "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";

            # Media
            "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
            "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
            "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
            "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl stop";

            # Notifications
            "${modifier}+w" = "exec ${notifier.dismiss-cmd}";

            # Programs
            "${modifier}+v" = "exec ${editor.cmd}";
            "${modifier}+m" = "exec ${mail.cmd}";
            "${modifier}+b" = "exec ${browser.cmd}";

            # Screenshot
            # Current monitor
            "Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify copy output";
            # Current window
            "Shift+Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify copy active";
            # Entire screen
            "Control+Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify copy screen";
            # Pick area
            "Mod1+Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify copy area";
            # Pick window
            "${modifier}+Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify copy window";

            # Application menu
            "${modifier}+x" = "exec ${menu.drun-cmd}";

            # Pass menu
            "Scroll_Lock" = "exec ${menu.password-cmd}"; # fn+k
            "XF86Calculator" = "exec ${menu.password-cmd}"; # fn+f12

            # Full screen across monitors
            "${modifier}+shift+f" = "fullscreen toggle global";
          };
      };
    };
}
