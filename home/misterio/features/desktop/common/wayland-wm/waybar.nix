{ config, lib, pkgs, ... }:

let
  inherit (pkgs.lib) optionals optional;
  inherit (config.home.preferredApps) menu terminal;

  # Dependencies
  jq = "${pkgs.jq}/bin/jq";
  xml = "${pkgs.xmlstarlet}/bin/xml";
  gamemoded = "${pkgs.gamemode}/bin/gamemoded";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  journalctl = "${pkgs.systemd}/bin/journalctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  playerctld = "${pkgs.playerctl}/bin/playerctld";
  lyrics = "${pkgs.lyrics}/bin/lyrics";

  # Function to simplify making waybar outputs
  jsonOutput = name: { pre ? "", text ? "", tooltip ? "", alt ? "", class ? "", percentage ? "" }: "${pkgs.writeShellScriptBin "waybar-${name}" ''
    set -euo pipefail
    ${pre}
    ${jq} -cn \
      --arg text "${text}" \
      --arg tooltip "${tooltip}" \
      --arg alt "${alt}" \
      --arg class "${class}" \
      --arg percentage "${percentage}" \
      '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
  ''}/bin/waybar-${name}";
in
{
  programs.waybar = {
    enable = true;
    settings = {

      secondary = {
        mode = "dock";
        layer = "top";
        height = 32;
        width = 100;
        margin = "6";
        position = "bottom";
        modules-center = (optionals config.wayland.windowManager.sway.enable [
          "sway/workspaces"
          "sway/mode"
        ]) ++ (optionals config.wayland.windowManager.hyprland.enable [
          "wlr/workspaces"
        ]);

        "wlr/workspaces" = {
          on-click = "activate";
        };
      };

      primary = {
        mode = "dock";
        layer = "top";
        height = 40;
        margin = "6";
        position = "top";
        output = builtins.map (m: m.name) (builtins.filter (m: m.isSecondary == false) config.monitors);
        modules-left = [
          "custom/menu"
          "custom/currentplayer"
          "custom/player"
        ];
        modules-center = [
          "cpu"
          "custom/gpu"
          "memory"
          "clock"
          "pulseaudio"
          "custom/unread-mail"
          "custom/gammastep"
          "custom/gpg-agent"
        ];
        modules-right = [
          "custom/gamemode"
          "network"
          "custom/tailscale-ping"
          "battery"
          "tray"
          "custom/hostname"
        ];

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
          interval = 5;
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
          interval = 10;
          format-icons = [ "" "" "" "" "" "" "" "" "" "" ];
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
        };
        "sway/window" = {
          max-length = 20;
        };
        network = {
          interval = 3;
          format-wifi = "   {essid}";
          format-ethernet = " Connected";
          format-disconnected = "";
          tooltip-format = ''
            {ifname}
            {ipaddr}/{cidr}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
        };
        "custom/tailscale-ping" = {
          interval = 2;
          return-type = "json";
          exec =
            let
              targets = {
                electra = { host = "electra"; icon = " "; };
                merope = { host = "merope"; icon = " "; };
                atlas = { host = "atlas"; icon = " "; };
                maia = { host = "maia"; icon = " "; };
                pleione = { host = "pleione"; icon = " "; };
              };

              showPingCompact = { host, icon }: "${icon} $ping_${host}";
              showPingLarge = { host, icon }: "${icon} ${host}: $ping_${host}";
              setPing = { host, ... }: ''
                ping_${host}="$(timeout 2 ping -c 1 -q ${host} 2>/dev/null | tail -1 | cut -d '/' -f5 | cut -d '.' -f1)ms" || ping_${host}="Disconnected"
              '';
            in
            jsonOutput "tailscale-ping" {
              pre = ''
                set -o pipefail
                ${builtins.concatStringsSep "\n" (map setPing (builtins.attrValues targets))}
              '';
              text = "${showPingCompact targets.electra} / ${showPingCompact targets.merope}";
              tooltip = builtins.concatStringsSep "\n" (map showPingLarge (builtins.attrValues targets));
            };
          format = "{}";
        };
        "custom/menu" = {
          return-type = "json";
          exec = jsonOutput "menu" {
            text = "";
            tooltip = ''$(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2)'';
          };
          on-click = menu.drun-cmd;
        };
        "custom/hostname" = {
          exec = "echo $USER@$(hostname)";
        };
        "custom/unread-mail" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "unread-mail" {
            pre = ''
              count=$(find ~/Mail/*/Inbox/new -type f | wc -l)
              if [ "$count" == "0" ]; then
                subjects="No new mail"
                status="read"
              else
                subjects=$(\
                  grep -h "Subject: " -r ~/Mail/*/Inbox/new | cut -d ':' -f2- | \
                  perl -CS -MEncode -ne 'print decode("MIME-Header", $_)' | ${xml} esc | sed -e 's/^/\-/'\
                )
                status="unread"
              fi
              if pgrep mbsync &>/dev/null; then
                status="syncing"
              fi
            '';
            text = "$count";
            tooltip = "$subjects";
            alt = "$status";
          };
          format = "{icon}  ({})";
          format-icons = {
            "read" = "";
            "unread" = "";
            "syncing" = "";
          };
        };
        "custom/gpg-agent" = {
          interval = 2;
          return-type = "json";
          exec =
            let keyring = import ../../../trusted/keyring.nix { inherit pkgs; };
            in
            jsonOutput "gpg-agent" {
              pre = ''status=$(${keyring.isUnlocked} && echo "unlocked" || echo "locked")'';
              alt = "$status";
              tooltip = "GPG is $status";
            };
          format = "{icon}";
          format-icons = {
            "locked" = "";
            "unlocked" = "";
          };
        };
        "custom/gamemode" = {
          exec-if = "${gamemoded} --status | grep 'is active' -q";
          interval = 2;
          return-type = "json";
          exec = jsonOutput "gamemode" {
            tooltip = "Gamemode is active";
          };
          format = " ";
        };
        "custom/gammastep" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "gammastep" {
            pre = ''
              if unit_status="$(${systemctl} --user is-active gammastep)"; then
                status="$unit_status ($(${journalctl} --user -u gammastep.service -g 'Period: ' | tail -1 | cut -d ':' -f6 | xargs))"
              else
                status="$unit_status"
              fi
            '';
            alt = "\${status:-inactive}";
            tooltip = "Gammastep is $status";
          };
          format = "{icon}";
          format-icons = {
            "activating" = " ";
            "deactivating" = " ";
            "inactive" = "? ";
            "active (Night)" = " ";
            "active (Nighttime)" = " ";
            "active (Transition (Night)" = " ";
            "active (Transition (Nighttime)" = " ";
            "active (Day)" = " ";
            "active (Daytime)" = " ";
            "active (Transition (Day)" = " ";
            "active (Transition (Daytime)" = " ";
          };
          on-click = "${systemctl} --user is-active gammastep && ${systemctl} --user stop gammastep || ${systemctl} --user start gammastep";
        };
        "custom/gpu" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "gpu" {
            text = "$(cat /sys/class/drm/card0/device/gpu_busy_percent)";
            tooltip = "GPU Usage";
          };
          format = "力  {}%";
        };
        "custom/currentplayer" = {
          interval = 2;
          return-type = "json";
          exec = jsonOutput "currentplayer" {
            pre = ''player="$(${playerctl} status -f "{{playerName}}" 2>/dev/null || echo "No players found" | cut -d '.' -f1)"'';
            alt = "$player";
            tooltip = "$player";
          };
          format = "{icon}";
          format-icons = {
            "No players found" = "ﱘ";
            "Celluloid" = "";
            "spotify" = "阮";
            "ncspot" = "阮";
            "qutebrowser" = "爵";
            "discord" = "ﭮ";
            "sublimemusic" = "";
          };
          on-click = "${playerctld} shift";
          on-click-right = "${playerctld} unshift";
        };
        "custom/player" = {
          exec-if = "${playerctl} status";
          exec = ''${playerctl} metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{title}} ({{artist}} - {{album}})"}' '';
          return-type = "json";
          interval = 2;
          max-length = 30;
          format = "{icon} {}";
          format-icons = {
            "Playing" = "契";
            "Paused" = " ";
            "Stopped" = "栗";
          };
          on-click = "${playerctl} play-pause";
          on-click-right = terminal.cmd-spawn "${lyrics}";
        };
      };

    };
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style =
      let inherit (config.colorscheme) colors; in
      ''
        * {
          font-family: ${config.fontProfiles.regular.family}, ${config.fontProfiles.monospace.family};
          font-size: 12pt;
          padding: 0 8px;
        }

        .modules-right {
          margin-right: -15;
        }

        .modules-left {
          margin-left: -15;
        }

        window#waybar.top {
          color: #${colors.base05};
          opacity: 0.95;
          background-color: #${colors.base00};
          border: 2px solid #${colors.base0C};
          padding: 0;
          border-radius: 10px;
        }
        window#waybar.bottom {
          color: #${colors.base05};
          background-color: #${colors.base00};
          border: 2px solid #${colors.base0C};
          opacity: 0.90;
          border-radius: 10px;
        }

        #workspaces button {
          background-color: #${colors.base01};
          color: #${colors.base05};
          margin: 4px;
        }
        #workspaces button.hidden {
          background-color: #${colors.base00};
          color: #${colors.base04};
        }
        #workspaces button.focused,
        #workspaces button.active {
          background-color: #${colors.base0A};
          color: #${colors.base00};
        }

        #clock {
          background-color: #${colors.base0C};
          color: #${colors.base00};
          padding-left: 15px;
          padding-right: 15px;
          margin-top: 0;
          margin-bottom: 0;
          border-radius: 10px;
        }

        #custom-menu {
          background-color: #${colors.base0C};
          color: #${colors.base00};
          padding-left: 15px;
          padding-right: 22px;
          margin-left: 0;
          margin-right: 10px;
          margin-top: 0;
          margin-bottom: 0;
          border-radius: 10px;
        }
        #custom-hostname {
          background-color: #${colors.base0C};
          color: #${colors.base00};
          padding-left: 15px;
          padding-right: 18px;
          margin-right: 0;
          margin-top: 0;
          margin-bottom: 0;
          border-radius: 10px;
        }
      '';
  };
}
