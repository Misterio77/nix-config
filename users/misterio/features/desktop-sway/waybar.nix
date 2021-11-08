{ config, features, lib, pkgs, ... }:

let
  keyring = import ../trusted/keyring.nix { inherit pkgs; };
in {
  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      height = 42;
      position = "top";
      modules-left = [
        "custom/menu"
        "sway/workspaces"
        "sway/mode"
        "custom/minicava"
        "custom/preferredplayer"
        "custom/player"
      ];
      modules-center = [ "sway/window" ];
      modules-right = [
        "custom/gamemode"
        "custom/ethminer"
        "custom/theme"
        "pulseaudio"
        "cpu"
        "custom/gpu"
        "memory"
        "custom/unread-mail"
        "clock"
        "tray"
        "custom/gpg-agent"
      ];
      modules = {
        clock = {
          format = "{:%d/%m %H:%M}";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
        };
        cpu = {
          format = "{usage}% ";
          tooltip = false;
        };
        memory = { format = "{}% "; };
        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "0%  ";
          format-icons = {
            headphone = "";
            headset = "";
            portable = "";
            default = [ "" "" "" ];
          };
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };
        "sway/window" = { max-length = 50; };
        "sway/workspaces" = {
          format = "{icon} {name}";
          format-icons = {
            focused = "綠";
            default = "祿";
          };
        };
        "custom/menu" = let
          wofi = "${pkgs.wofi}/bin/wofi";
        in {
          format = "";
          on-click = "${wofi} -S drun -I";
        };
        "custom/unread-mail" = {
          exec = ''
            echo "  ($(find ~/Mail/*/INBOX/new -type f | wc -l))"
          '';
          on-click = "${pkgs.kitty}/bin/kitty -e ${pkgs.neomutt}/bin/neomutt";
          interval = 2;
        };
        "custom/gpg-agent" = lib.mkIf (builtins.elem "trusted" features) {
          # Check if GPG Agent is caching passphrase
          exec = ''
            ${keyring.isUnlocked} && echo -e "\nGPG is unlocked" || echo -e "\nGPG is locked"
          '';
          # Lock or unlock GPG agent
          on-click = ''
            ${keyring.isUnlocked} && ${keyring.lock} || ${keyring.unlock}
          '';
          interval = 1;
        };
        "custom/ethminer" = {
          exec-if = "systemctl --user is-active ethminer";
          exec =
            "journalctl --user -n 10 -u ethminer | grep '-e \\ m\\ .*' | cut -d ' ' -f12-13";
          interval = 1;
          format = "{} ﲹ";
        };
        "custom/gamemode" = {
          exec-if = "${pkgs.gamemode}/bin/gamemoded --status | grep 'is active' -q";
          interval = 2;
          exec = "echo '' && echo 'Gamemode is active'";
        };
        "custom/theme" = {
          exec = "echo '  ${config.colorscheme.slug}'";
          on-click = "${pkgs.setscheme-wofi}/bin/setscheme-wofi";
        };
        "custom/gpu" = {
          exec = "cat /sys/class/drm/card0/device/gpu_busy_percent";
          interval = 2;
          format = "{}% 力";
        };
        "custom/preferredplayer" = {
          exec = ''
            ${pkgs.jq}/bin/jq -c -n --arg text "$(player=$(${pkgs.preferredplayer}/bin/preferredplayer) && echo $player | cut -d '.' -f 1 || echo No player set)" '{text: $text, alt: $text, tooltip: $text}'
          '';
          return-type = "json";
          interval = 1;
          format = "{icon}";
          tooltip = true;
          format-icons = {
            "Celluloid" = "";
            "spotify" = "阮";
            "qutebrowser" = "爵";
            "discord" = "ﭮ";
            "No player set" = "ﱘ";
          };
        };
        "custom/player" = let
          playerctl = "${pkgs.playerctl}/bin/playerctl";
          preferredplayer = "${pkgs.preferredplayer}/bin/preferredplayer";
        in {
          exec-if = ''
            [[ "$(player=$(${preferredplayer}) && ${playerctl} --player $player status)" != "Stopped" ]]'';
          exec = ''
            player=$(${preferredplayer}) && ${playerctl} --player $player metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{title}} ({{artist}} - {{album}})"}';
          '';
          return-type = "json";
          interval = 1;
          max-length = 35;
          format = "{icon}  {}";
          format-icons = {
            "Playing" = "契";
            "Paused" = "";
            "Stopped" = "栗";
          };
        };
        "custom/minicava" = {
          "exec" = "${pkgs.nur.repos.misterio.minicava}/bin/minicava";
          "restart-interval" = 5;
        };
      };
    }];
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style = let
      colors = config.colorscheme.colors;
    in ''
      * {
        border: none;
        border-radius: 0;
        font-family: Fira Sans, Fira Code NerdFont;
        font-size: 12pt;
        margin: 1px 0;
        padding: 0 8px;
      }

      window#waybar {
        color: #${colors.base05};
        background-color: #${colors.base00};
        border-bottom: 2px solid #${colors.base0C};
      }

      #workspaces button {
        margin: 0;
      }
      #workspaces button.visible,
      #workspaces button.focused {
        background-color: #${colors.base01};
        color: #${colors.base04};
      }
      #workspaces button.focused {
        color: #${colors.base0A};
      }

      #pulseaudio {
        padding: 0 8px;
      }

      #clock {
        background-color: #${colors.base0C};
        color: #${colors.base00};
        margin: 0;
        padding: 0 12px;
      }

      #custom-menu {
        background-color: #${colors.base0B};
        color: #${colors.base00};
        margin: 0 0 0 -15;
        padding: 0 20px 0 15px;
      }

      #custom-preferredplayer {
        margin-right: 2px;
        margin-left: 10px;
      }

      #custom-player {
        margin-left: 2px;
        margin-right: 10px;
      }

    '';
  };
}
