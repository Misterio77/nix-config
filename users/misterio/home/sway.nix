{ lib, pkgs, config, ... }:

let
  colors = config.colorscheme.colors;
  wallpaper = config.wallpaper.path;
  swayfader-pkg = pkgs.stdenv.mkDerivation {
    name = "swayfader";
    src = pkgs.fetchFromGitHub {
      owner = "Misterio77";
      repo = "swayfader";
      rev = "3f18eacb4b43ffd2d8c10a395a3e77bbb40ccee6";
      sha256 = "0x490g1g1vjrybnwna9z00r9i61d5sbrzq7qi7mdq6y94whwblla";
    };
    buildInputs = [ (pkgs.python3.withPackages (ps: [ ps.i3ipc ])) ];
    dontBuild = true;
    dontConfigure = true;
    installPhase = "install -Dm 0755 $src/swayfader.py $out/bin/swayfader";
  };
  # Programs
  alacritty = "${pkgs.alacritty-reload}/bin/alacritty";
  grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
  makoctl = "${pkgs.mako}/bin/makoctl";
  nvim = "${pkgs.neovim}/bin/nvim";
  octave = "${pkgs.octave}/bin/octave";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  qutebrowser = "${pkgs.qutebrowser}/bin/qutebrowser";
  swayfader = "${swayfader-pkg}/bin/swayfader";
  swayidle = "${pkgs.swayidle}/bin/swayidle";
  wofi = "${pkgs.wofi}/bin/wofi -t ${alacritty}";
  xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
  zathura = "${pkgs.zathura}/bin/zathura";
  # Swaylock with color arguments
  swaylock-command = import ./swaylock-command.nix {
    package = pkgs.swaylock-effects;
    colors = colors;
  };
in {
  home.packages = with pkgs; [ wl-clipboard wf-recorder ];

  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    wrapperFeatures.gtk = true;
    config = {
      bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];
      menu = "${wofi} -S run";
      fonts = {
        names = [ "Fira Sans" ];
        size = 12.0;
      };
      output = {
        DP-1 = {
          res = "1920x1080@60hz";
          pos = "0 0";
          bg = "${config.wallpaper.path} fill";
        };
        HDMI-A-1 = {
          res = "2560x1080@75hz";
          pos = "1920 70";
          bg = "${config.wallpaper.path} fill";
        };
      };
      defaultWorkspace = "workspace number 1";
      workspaceOutputAssign = [
        {
          output = "HDMI-A-1";
          workspace = "1";
        }
        {
          output = "DP-1";
          workspace = "2";
        }
      ];
      colors = {
        focused = {
          border = "${colors.base0C}";
          childBorder = "${colors.base0C}";
          indicator = "${colors.base09}";
          background = "${colors.base00}";
          text = "${colors.base05}";
        };
        focusedInactive = {
          border = "${colors.base03}";
          childBorder = "${colors.base03}";
          indicator = "${colors.base03}";
          background = "${colors.base00}";
          text = "${colors.base04}";
        };
        unfocused = {
          border = "${colors.base02}";
          childBorder = "${colors.base02}";
          indicator = "${colors.base02}";
          background = "${colors.base00}";
          text = "${colors.base03}";
        };
        urgent = {
          border = "${colors.base09}";
          childBorder = "${colors.base09}";
          indicator = "${colors.base09}";
          background = "${colors.base00}";
          text = "${colors.base03}";
        };
      };
      startup = [
        # Initial lock
        #{
          #command = "'${swaylock-command} -i ${wallpaper}'";
        #}
        # Focus main output
        {
          command = "swaymsg focus output HDMI-A-1";
        }
        # Add transparency
        {
          command = "${swayfader}";
        }
        # Swayidle
        # Lock after 10 minutes
        # Turn screen off and clear gpg pass after 20 seconds locked
        {
          command = ''
            ${swayidle} -w \
                      timeout 600 '${swaylock-command} --screenshots --daemonize' \
                      timeout 10 'pgrep -x swaylock && pactl set-source-mute @DEFAULT_SOURCE@ yes' \
                          resume 'pgrep -x swaylock && pactl set-source-mute @DEFAULT_SOURCE@ no' \
                      timeout 610 'pactl set-source-mute @DEFAULT_SOURCE@ yes' \
                          resume 'pactl set-source-mute @DEFAULT_SOURCE@ no' \
                      timeout 20  'pgrep -x swaylock && systemctl --user stop rgbdaemon' \
                          resume  'pgrep -x swaylock && systemctl --user start rgbdaemon' \
                      timeout 620 'systemctl --user stop rgbdaemon' \
                          resume  'systemctl --user start rgbdaemon' \
                        timeout 20  'pgrep -x swaylock && swaymsg "output * dpms off"' \
                          resume  'pgrep -x swaylock && swaymsg "output * dpms on"' \
                      timeout 620 'swaymsg "output * dpms off"' \
                          resume  'swaymsg "output * dpms on"' \
                      timeout 20  'pgrep -x swaylock && gpg-connect-agent reloadagent /bye' \
                      timeout 620 'gpg-connect-agent reloadagent /bye'
          '';
        }
        # Set xwayland main monitor
        {
          command =
            "${xrandr} --output $(${xrandr} | grep 'XWAYLAND.*2560x1080' | awk '{printf $1}') --primary";
        }
      ];
      window = {
        border = 2;
        commands = [{
          command = "move scratchpad";
          criteria = { title = "Wine System Tray"; };
        }];
      };
      keybindings = lib.mkOptionDefault {
        # Splits
        "Mod4+minus" = "split v";
        "Mod4+backslash" = "split h";
        # Scratchpad
        "Mod4+u" = "scratchpad show";
        "Mod4+Shift+u" = "move scratchpad";
        # Move entire workspace
        "Mod4+Mod1+h" = "move workspace to output left";
        "Mod4+Mod1+Left" = "move workspace to output left";
        "Mod4+Mod1+l" = "move workspace to output right";
        "Mod4+Mod1+Right" = "move workspace to output right";
        # Toggle monitors
        "Mod4+Control+Left" = "output DP-1 toggle";
        "Mod4+Control+Down" = "output HDMI-A-1 toggle";
        # Lock screen
        "XF86Launch5" = "exec ${swaylock-command} --screenshots";
        # Volume
        "XF86AudioRaiseVolume" =
          "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +1%";
        "XF86AudioLowerVolume" =
          "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -1%";
        "Shift+XF86AudioRaiseVolume" =
          "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
        "Shift+XF86AudioLowerVolume" =
          "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
        "Shift+XF86AudioMute" =
          "exec ${pactl} set-source-mute @DEFAULT_SINK@ toggle";
        # Media
        "XF86AudioNext" = "exec ${playerctl} next";
        "XF86AudioPrev" = "exec ${playerctl} previous";
        "XF86AudioPlay" = "exec ${playerctl} play-pause";
        "XF86AudioStop" = "exec ${playerctl} stop";
        # RGB Lights
        # TODO
        # Notifications
        "Mod4+w" = "exec ${makoctl} dismiss";
        "Mod4+shift+w" = "exec ${makoctl} dismiss -a";
        # Programs
        "Mod4+v" = "exec ${alacritty} -e ${nvim}";
        "Mod4+o" = "exec ${alacritty} -e ${octave}";
        "Mod4+b" = "exec ${qutebrowser}";
        "Mod4+z" = "exec ${zathura}";
        "Mod4+control+w" = "exec ${makoctl} invoke";
        # Screenshot
        "Print" = "exec ${grimshot} --notify copy output";
        "Shift+Print" = "exec ${grimshot} --notify copy active";
        "Control+Print" = "exec ${grimshot} --notify copy screen";
        "Mod1+Print" = "exec ${grimshot} --notify copy area";
        "Mod4+Print" = "exec ${grimshot} --notify copy window";
      };
      terminal = "${alacritty}";
      modifier = "Mod4";
      input = {
        "6940:6985:Corsair_CORSAIR_K70_RGB_MK.2_Mechanical_Gaming_Keyboard" = {
          xkb_layout = "br";
        };
        "6940:6985:ckb1:_CORSAIR_K70_RGB_MK.2_Mechanical_Gaming_Keyboard_vKB" =
          {
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
