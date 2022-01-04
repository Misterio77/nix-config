{ config, features, lib, pkgs, ... }:

let keyring = import ../trusted/keyring.nix { inherit pkgs; };
in
{
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
        "custom/preferredplayer"
        "custom/player"
      ];
      modules-center = [
        "cpu"
        "custom/gpu"
        "memory"
        "clock"
        "pulseaudio"
        "custom/unread-mail"
        "custom/gpg-agent"
      ];
      modules-right = [
        "custom/gamemode"
        "custom/ethminer"
        "custom/theme"
        "network"
        "custom/home"
        "battery"
        "tray"
      ];
      modules = {
        clock = {
          format = "{:%d/%m %H:%M}";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
        };
        cpu = {
          format = "   {usage}%";
        };
        memory = {
          format = "  {}%";
          interval = 4;
        };
        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "   0%";
          format-icons = {
            headphone = "";
            headset = "";
            portable = "";
            default = [ "" "" "" ];
          };
        };
        battery = {
          bat = "BAT0";
          interval = 40;
          format-icons = [ "" "" "" "" "" "" "" "" "" "" ];
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
        };
        "sway/window" = {
          max-length = 20;
        };
        "sway/workspaces" = {
          format = "{icon} {name}";
          format-icons = {
            focused = "綠";
            default = "祿";
          };
        };
        network = {
          interval = 20;
          format-wifi = "   {essid}";
          format-ethernet = " {ipaddr}/{cidr}";
          format-disconnected = "";
        };
        "custom/home" = {
          interval = 5;
          exec = ''
            ping -qc1 merope.local 2>&1 | awk -F/ '/^rtt/ { printf "%.1fms", $5; ok = 1 } END { if (!ok) print "Disconnected" }'
          '';
          format = "  {}";
        };
        "custom/menu" = {
          format = "";
          on-click = "${pkgs.wofi}/bin/wofi -S drun";
        };
        "custom/unread-mail" = {
          exec = "find ~/Mail/*/INBOX/new -type f | wc -l";
          format = "  ({})";
          interval = 5;
        };
        "custom/gpg-agent" = lib.mkIf (builtins.elem "trusted" features) {
          # Check if GPG Agent is caching passphrase
          exec = ''
            ${keyring.isUnlocked} && echo -e "\nGPG is unlocked" || echo -e "\nGPG is locked"
          '';
          interval = 5;
        };
        "custom/ethminer" = {
          exec-if = "systemctl --user is-active ethminer";
          exec =
            "journalctl --user -n 10 -u ethminer | grep '-e \\ m\\ .*' | cut -d ' ' -f12-13";
          interval = 2;
          format = "{}";
        };
        "custom/gamemode" = {
          exec-if =
            "${pkgs.gamemode}/bin/gamemoded --status | grep 'is active' -q";
          interval = 2;
          exec = ''
            echo '{"tooltip": "Gamemode is active"}'
          '';
          format = "";
        };
        "custom/theme" = {
          format = "  ${config.colorscheme.slug}";
        };
        "custom/gpu" = {
          exec = "cat /sys/class/drm/card0/device/gpu_busy_percent";
          interval = 3;
          format = "力  {}%";
        };
        "custom/preferredplayer" = {
          exec = ''
            player="$(${pkgs.preferredplayer}/bin/preferredplayer || echo No player set)"; \
            echo "{\"alt\": \"$player\", \"tooltip\": \"$player \"}"
          '';
          return-type = "json";
          interval = 2;
          format = "{icon}";
          format-icons = {
            "Celluloid" = "";
            "spotify" = "阮";
            "qutebrowser" = "爵";
            "discord" = "ﭮ";
            "No player set" = "ﱘ";
          };
        };
        "custom/player" =
          let
            playerctl = "${pkgs.playerctl}/bin/playerctl";
            preferredplayer = "${pkgs.preferredplayer}/bin/preferredplayer";
          in
          {
            exec-if = ''
              [[ "$(player=$(${preferredplayer}) && ${playerctl} --player $player status)" != "Stopped" ]]'';
            exec = ''
              player=$(${preferredplayer}) && ${playerctl} --player $player metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{title}} ({{artist}} - {{album}})"}';
            '';
            return-type = "json";
            interval = 2;
            max-length = 30;
            format = "{icon} {}";
            format-icons = {
              "Playing" = "契";
              "Paused" = "";
              "Stopped" = "栗";
            };
          };
      };
    }];
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style =
      let colors = config.colorscheme.colors;
      in
      ''
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
          background-color: #${colors.base01};
          border-bottom: 2px solid #${colors.base0C};
        }

        #workspaces button {
          margin: 0;
        }
        #workspaces button.visible,
        #workspaces button.focused {
          background-color: #${colors.base00};
          color: #${colors.base04};
        }
        #workspaces button.focused {
          color: #${colors.base0A};
        }

        #clock {
          background-color: #${colors.base0C};
          color: #${colors.base00};
          padding-left: 15px;
          padding-right: 15px;
          margin-top: 0;
          margin-bottom: 0;
        }

        #custom-menu {
          background-color: #${colors.base0B};
          color: #${colors.base00};
          padding-left: 15px;
          padding-right: 22px;
          margin-left: -15;
          margin-top: 0;
          margin-bottom: 0;
        }
      '';
  };
}
