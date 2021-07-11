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
    buildInputs = with pkgs; [
      (python3.withPackages (ps: with ps; [ i3ipc ]))
    ];
    dontBuild = true;
    dontConfigure = true;
    installPhase = ''
      install -Dm 0755 $src/swayfader.py $out/bin/swayfader
    '';
  };
  # Get custom swaylock command
  swaylock = import ./swaylock-custom.nix {
    package = pkgs.swaylock-effects;
    # Pass our colorscheme
    colors = colors;
  };
in {
  home.packages = with pkgs; [
    wl-clipboard
    wf-recorder
  ];

  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    wrapperFeatures.gtk = true;
    config = {
      bars = [ ];
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
          output = "DPI-1";
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
      startup = let
        xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
        swayidle = "${pkgs.swayidle}/bin/swayidle";
        swayfader = "${swayfader-pkg}/bin/swayfader";
      in [
        # Initial lock
        {
          command = "'${swaylock} -i ${wallpaper}'";
        }
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
                      timeout 600 '${swaylock} --screenshots --daemonize' \
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
          command = "${xrandr} --output $(${xrandr} | grep 'XWAYLAND.*2560x1080' | awk '{printf $1}') --primary";
        }
      ];
      window = { border = 2; };
      keybindings = 
      let
        grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
        makoctl = "${pkgs.mako}/bin/makoctl";
        zathura = "${pkgs.zathura}/bin/zathura";
        browser = "${pkgs.qutebrowser}/bin/qutebrowser";
      in lib.mkOptionDefault {
        "Mod4+minus" = "split v";
        "Mod4+backslash" = "split h";
        "Mod4+u" = "scratchpad show";
        "Mod4+Shift+u" = "move scratchpad";
        "XF86Launch5" = "exec ${swaylock} --screenshots";
        "Mod4+b" = "exec ${browser}";
        "Mod4+z" = "exec ${zathura}";
        "Mod4+w" = "exec ${makoctl} dismiss";
        "Mod4+shift+w" = "exec ${makoctl} dismiss -a";
        "Mod4+control+w" = "exec ${makoctl} invoke";
        "Shift+Print" = "exec ${grimshot} --notify copy active";
        "Control+Print" = "exec ${grimshot} --notify copy screen";
        "Print" = "exec ${grimshot} --notify copy output";
        "Mod1+Print" = "exec ${grimshot} --notify copy area";
        "Mod4+Print" = "exec ${grimshot} --notify copy window";
      };
      workspaceAutoBackAndForth = true;
      terminal = "${pkgs.alacritty}/bin/alacritty";
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
