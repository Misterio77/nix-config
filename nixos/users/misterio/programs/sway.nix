{ lib, pkgs, ... }: {
  home.packages = with pkgs; [
    dragon-drop
    swaylock
    swayidle
    swaybg
    sway-contrib.grimshot
    slurp
    grim
    wl-clipboard
    xorg.xrandr
  ];
  # Override swaylock with swaylock-effects
  nixpkgs.overlays = [
    (self: super: {
      swaylock = super.swaylock.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "mortie";
          repo = "swaylock-effects";
          rev = "705166727786725f6c8503f794f401536946a407";
          sha256 = "162aic40dfvlrz40zbzmhcmggihcdymxrfljxb7j7i5qy38iflpg";
        };
      });
    })
  ];

  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    wrapperFeatures.gtk = true;
    extraConfig = ''
      # Monitors
      ## Variables

      ## Resolution and disposition
      output DP-1   res 1920x1080@60Hz pos 0    0
      output HDMI-A-1 res 2560x1080@75Hz pos 1920 80
      #adaptive_sync on max_render_time 1

      ## Workspaces
      workspace 1 output HDMI-A-1
      workspace 2 output DP-1

      ## First focused workspace
      exec swaymsg focus output $mcenter

      # Colors
      include ~/.config/sway/colors
      client.focused $base00 $base02 $base00 $base03 $base05
      client.focused_inactive $base00 $base02 $base00 $base04 $base04
      client.unfocused $base00 $base02 $base00 $base04 $base04
      client.urgent $base00 $base02 $base00 $base09 $base09
      client.background $base00
    '';
    config = {
      bars = [ ];
      startup = [
        # Set initial theme, wallpaper, and lock screen
        {
          command = "initial_theming.sh";
        }
        # Focus main output
        {
          command = "swaymsg focus output HDMI-A-1";
        }
        # Swayidle
        {
          command = ''
            swayidle -w \
                      timeout 600 'swaylock.sh --screenshots --daemonize' \
                      timeout 20  'pgrep -x swaylock && swaymsg "output * dpms off"' \
                          resume  'pgrep -x swaylock && swaymsg "output * dpms on"' \
                      timeout 620 'swaymsg "output * dpms off"' \
                          resume  'swaymsg "output * dpms on"' \
                      timeout 20  'pgrep -x swaylock && gpg-connect-agent reloadagent /bye' \
                      timeout 620 'gpg-connect-agent reloadagent /bye
          '';
        }
        # Add transparency
        {
          command = "swayfader.sh";
          always = true;
        }
        # Set xwayland main monitor
        {
          command = ''
            exec_always "xrandr --output $(xrandr | grep "XWAYLAND.*2560x1080" | awk '{printf $1}') --primary"'';
          always = true;
        }
      ];
      window = { border = 2; };
      keybindings = lib.mkOptionDefault {
        "Mod4+minus" = "split v";
        "Mod4+backslash" = "split h";
        "Mod4+u" = "scratchpad show";
        "Mod4+Shift+u" = "move scratchpad";
        "Mod4+b" = "exec qutebrowser";
        "Mod4+z" = "exec zathura";
        "Mod4+w" = "exec makoctl dismiss";
        "Mod4+shift+w" = "exec makoctl dismiss -a";
        "Mod4+control+w" = "exec makoctl invoke";
        "Shift+Print" = "exec grimshot --notify copy active";
        "Control+Print" = "exec grimshot --notify copy screen";
        "Print" = "exec grimshot --notify copy output";
        "Mod1+Print" = "exec grimshot --notify copy area";
        "Mod4+Print" = "exec grimshot --notify copy window";
      };
      workspaceAutoBackAndForth = true;
      terminal = "alacritty";
      modifier = "Mod4";
      input = {
        "6940:6985:Corsair_CORSAIR_K70_RGB_MK.2_Mechanical_Gaming_Keyboard" = {
          xkb_layout = "br";
        };
        "6940:6985:ckb1:_CORSAIR_K70_RGB_MK.2_Mechanical_Gaming_Keyboard_vKB" = {
          xkb_layout = "br";
        };
        "6940:7051:ckb2:_CORSAIR_SCIMITAR_RGB_ELITE_Gaming_Mouse_vM" = {
          pointer_accel = "1";
        };
      };
      gaps = {
        horizontal = 5;
        inner = 28;
      };
    };
  };
}
