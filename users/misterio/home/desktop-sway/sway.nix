{ lib, trusted, pkgs, config, hostname, ... }:

let
  # Programs
  amfora = "${pkgs.amfora}/bin/amfora";
  discocss = "${pkgs.discocss}/bin/discocss";
  grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
  kitty = "${config.programs.kitty.package}/bin/kitty";
  light = "${pkgs.light}/bin/light";
  makoctl = "${pkgs.mako}/bin/makoctl";
  neomutt = "${pkgs.neomutt}/bin/neomutt";
  nvim = "${pkgs.neovim}/bin/nvim";
  octave = "${pkgs.octave}/bin/octave";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  pass-wofi = "${pkgs.pass-wofi.override {pass = config.programs.password-store.package;}}/bin/pass-wofi";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  preferredplayer = "${pkgs.preferredplayer}/bin/preferredplayer";
  qutebrowser = "${pkgs.qutebrowser}/bin/qutebrowser";
  swayfader = "${pkgs.swayfader}/bin/swayfader";
  swayidle = "${pkgs.swayidle}/bin/swayidle";
  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
  wofi = "${pkgs.wofi}/bin/wofi";
  xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
  zathura = "${pkgs.zathura}/bin/zathura";

  inherit (config.colorscheme) colors;
  modifier = "Mod4";
  terminal = kitty;
in {
  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    wrapperFeatures.gtk = true;
    config = {
      inherit modifier terminal;
      menu = "${wofi} -S run";
      fonts = {
        names = [ config.fontProfiles.regular.family ];
        size = 12.0;
      };
      output =
        if hostname == "pleione" then {
          eDP-1 = {
            res = "1920x1080@60hz";
            pos = "0 0";
            bg = "${config.wallpaper} fill";
          };
        } else if hostname == "atlas" then {
          DP-1 = {
            res = "1920x1080@60hz";
            pos = "0 0";
            bg = "${config.wallpaper} fill";
          };
          HDMI-A-1 = {
            res = "2560x1080@75hz";
            pos = "1920 0";
            bg = "${config.wallpaper} fill";
          };
        } else { };
      defaultWorkspace = "workspace number 1";
      workspaceOutputAssign =
        if hostname == "pleione" then [
          {
            output = "eDP-1";
            workspace = "1";
          }
        ] else if hostname == "atlas" then [
          {
            output = "HDMI-A-1";
            workspace = "1";
          }
          {
            output = "DP-1";
            workspace = "2";
          }
        ] else [ ];
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
        { command = "${swaylock} -i ${config.wallpaper}"; }
        # Start idle daemon
        { command = "${swayidle} -w"; }
        # Add transparency
        { command = "SWAYFADER_CON_INAC=0.85 ${swayfader}"; }
        # Init discocss
        { command = "${discocss}"; }
      ] ++
      (if hostname == "atlas" then [{
        # Set primary monitor
        command = "${xrandr} --output $(${xrandr} | grep 'XWAYLAND.*2560x1080' | awk '{printf $1}') --primary";
      }] else [ ]);
      bars = [ ];
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
      keybindings = lib.mkOptionDefault {
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
        "${modifier}+Control+Left" = "output DP-1 toggle";
        "${modifier}+Control+Down" = "output HDMI-A-1 toggle";

        # Pass wofi menu
        "Scroll_Lock" = lib.mkIf trusted "exec ${pass-wofi}"; # fn+k
        "XF86Calculator" = lib.mkIf trusted "exec ${pass-wofi}"; # fn+f12

        # Unlock gpg
        "Shift+Scroll_Lock" =
          let keyring = import ../trusted/keyring.nix { inherit pkgs; };
          in lib.mkIf trusted "exec ${keyring.unlock}";

        # Lock screen
        "XF86Launch5" = "exec ${swaylock} -i ${config.wallpaper}"; # lock icon on k70
        "XF86Launch4" = "exec ${swaylock} -i ${config.wallpaper}"; # fn+q
        "${modifier}+p" = "exec ${swaylock} -i ${config.wallpaper}"; # fn+f7

        # Volume
        "XF86AudioRaiseVolume" =
          "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" =
          "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
        "Shift+XF86AudioMute" =
          "exec ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle";
        "XF86AudioMicMute" =
          "exec ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle";

        # Brightness
        "XF86MonBrightnessUp" = "exec ${light} -A 10";
        "XF86MonBrightnessDown" = "exec ${light} -U 10";

        # Media
        "XF86AudioNext" =
          "exec player=$(${preferredplayer}) && ${playerctl} next --player $player";
        "XF86AudioPrev" =
          "exec player=$(${preferredplayer}) && ${playerctl} previous --player $player";
        "XF86AudioPlay" =
          "exec player=$(${preferredplayer}) && ${playerctl} play-pause --player $player";
        "XF86AudioStop" =
          "exec player=$(${preferredplayer}) && ${playerctl} stop --player $player";
        "Shift+XF86AudioPlay" =
          "exec player=$(${playerctl} -l | ${wofi} -S dmenu) && ${preferredplayer} $player";
        "Shift+XF86AudioStop" = "exec ${preferredplayer} none";

        # Notifications
        "${modifier}+w" = "exec ${makoctl} dismiss";
        "${modifier}+shift+w" = "exec ${makoctl} dismiss -a";
        "${modifier}+control+w" = "exec ${makoctl} invoke";

        # Programs
        "${modifier}+v" = "exec ${terminal} $SHELL -i -c ${nvim}";
        "${modifier}+o" = "exec ${terminal} $SHELL -i -c ${octave}";
        "${modifier}+m" = "exec ${terminal} $SHELL -i -c ${neomutt}";
        "${modifier}+a" = "exec ${terminal} $SHELL -i -c ${amfora}";
        "${modifier}+b" = "exec ${qutebrowser}";
        "${modifier}+z" = "exec ${zathura}";

        # Screenshot
        "Print" = "exec ${grimshot} --notify copy output";
        "Shift+Print" = "exec ${grimshot} --notify copy active";
        "Control+Print" = "exec ${grimshot} --notify copy screen";
        "Mod1+Print" = "exec ${grimshot} --notify copy area";
        "${modifier}+Print" = "exec ${grimshot} --notify copy window";

        # Application menu
        "${modifier}+x" = "exec ${wofi} -S drun -x 10 -y 10 -W 25% -H 60%";

        # Full screen across monitors
        "${modifier}+shift+f" = "fullscreen toggle global";
      };
    };
    # https://github.com/NixOS/nixpkgs/issues/119445#issuecomment-820507505
    extraConfig = ''
      exec dbus-update-activation-environment WAYLAND_DISPLAY
      exec systemctl --user import-environment WAYLAND_DISPLAY
    '';
  };

  programs.zsh.loginExtra = lib.mkBefore ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      exec sway &> /dev/null
    fi
  '';
  programs.fish.loginShellInit = lib.mkBefore ''
    if test (tty) = /dev/tty1
      exec sway &> /dev/null
    end
  '';
  programs.bash.profileExtra = lib.mkBefore ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      exec sway &> /dev/null
    fi
  '';
}
