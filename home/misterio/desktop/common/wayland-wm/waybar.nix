{ config, features, lib, pkgs, mylib, desktop, ... }:

let
  trusted = mylib.has "trusted" features;
  jsonOutput = { pre ? "", text ? "", tooltip ? "", alt ? "", class ? "", percentage ? "" }: ''
    ${pre}
    ${jq} -cn \
      --arg text "${text}" \
      --arg tooltip "${tooltip}" \
      --arg alt "${alt}" \
      --arg class "${class}" \
      --arg percentage "${percentage}" \
      '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
  '';
  inherit (builtins) attrValues concatStringsSep mapAttrs;
  inherit (pkgs.lib) optionals;

  # Dependencies
  jq = "${pkgs.jq}/bin/jq";
  wofi = "${pkgs.wofi}/bin/wofi";
  xml = "${pkgs.xmlstarlet}/bin/xml";
  gamemoded = "${pkgs.gamemode}/bin/gamemoded";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
in
{
  programs. waybar = {
    enable = true;
    settings = [{
      layer = "top";
      height = 42;
      position = "top";
      modules-left = [
        "custom/menu"
      ] ++ (optionals (desktop == "sway") [
        "sway/workspaces"
        "sway/mode"
      ]) ++ (optionals (desktop == "hyprland") [
        "wlr/workspaces"
      ]) ++ [
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
        "custom/theme"
        "network"
        "custom/home"
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
        interval = 5;
        format-icons = [ "" "" "" "" "" "" "" "" "" "" ];
        format = "{icon} {capacity}%";
        format-charging = " {capacity}%";
      };
      "sway/window" = {
        max-length = 20;
      };
      "wlr/workspaces" = {
        format = "{icon} {name}";
        format-icons = {
          default = "祿";
          active = "綠";
        };
      };
      "sway/workspaces" = {
        format = "{icon} {name}";
        format-icons = {
          default = "祿";
          focused = "綠";
        };
      };
      network = {
        interval = 5;
        format-wifi = "   {essid}";
        format-ethernet = " Connected";
        format-disconnected = "";
        tooltip-format = ''
          {ifname}
          {ipaddr}/{cidr}
          Up: {bandwidthUpBits}
          Down: {bandwidthDownBits}'';
      };
      "custom/home" = {
        interval = 5;
        return-type = "json";
        exec =
          let
            ping = title: { icon, host }:
              let
                display = if (title == null) then icon else "${icon}  ${title}:";
              in
              ''${display} $(ping -qc4 ${host} 2>&1 | awk -F/ '/^rtt/ { printf "%.2fms", $5; ok = 1 } END { if (!ok) print "Disconnected" }')'';

            targets = {
              web = { host = "9.9.9.9"; icon = " "; };
              atlas = { host = "atlas"; icon = " "; };
              merope = { host = "merope"; icon = " "; };
              pleione = { host = "pleione"; icon = " "; };
            };
          in
          jsonOutput {
            text = "${ping null targets.web} / ${ping null targets.merope}";
            tooltip = concatStringsSep "\n" (attrValues (mapAttrs ping targets));
          };
        format = "{}";
      };
      "custom/menu" = {
        return-type = "json";
        exec = jsonOutput {
          text = "";
          tooltip = ''$(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2)'';
        };
        on-click = "${wofi} -S drun";
      };
      "custom/hostname" = {
        return-type = "json";
        exec = jsonOutput {
          text = "$(echo $USER)@$(hostname)";
        };
      };
      "custom/unread-mail" = {
        interval = 5;
        return-type = "json";
        exec = jsonOutput {
          pre = ''
            count=$(find ~/Mail/*/INBOX/new -type f | wc -l)
            if [ "$count" == "0" ]; then
              subjects="No new mail"
              status="read"
            else
              subjects=$(\
                grep -h "Subject: " -r ~/Mail/*/INBOX/new | cut -d ':' -f2- | \
                perl -CS -MEncode -ne 'print decode("MIME-Header", $_)' | ${xml} esc | sed -e 's/^/\-/'\
              )
              status="unread"
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
        };
      };
      "custom/gpg-agent" = lib.mkIf trusted {
        interval = 2;
        return-type = "json";
        exec =
          let
            keyring = import ../../../trusted/keyring.nix { inherit pkgs; };
          in
          jsonOutput {
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
        exec = jsonOutput {
          tooltip = "Gamemode is active";
        };
        format = " ";
      };
      "custom/gammastep" = {
        interval = 2;
        return-type = "json";
        exec = jsonOutput {
          pre = "status=$(${systemctl} is-active gammastep)";
          alt = "$status";
          tooltip = "Gammastep is $status";
        };
        format = "{icon}";
        format-icons = {
          "active" = " ";
          "activating" = "...";
          "inactive" = " ";
          "deactivating" = "...";
        };
        on-click = "${systemctl} is-active gammastep --quiet && ${systemctl} stop gammastep || ${systemctl} start gammastep";
      };
      "custom/theme" = {
        interval = 5;
        return-type = "json";
        max-length = 20;
        exec = jsonOutput {
          text = "${config.colorscheme.slug}";
          tooltip = "${config.colorscheme.name} theme";
        };
        format = "  {}";
      };
      "custom/gpu" = {
        interval = 5;
        return-type = "json";
        exec = jsonOutput {
          text = "$(cat /sys/class/drm/card0/device/gpu_busy_percent)";
          tooltip = "GPU Usage";
        };
        format = "力  {}%";
      };
      "custom/currentplayer" = {
        interval = 1;
        return-type = "json";
        exec = jsonOutput {
          pre = ''player="$(${playerctl} status -f "{{playerName}}" | cut -d '.' -f1)"'';
          alt = "$player";
          tooltip = "$player";
        };
        format = "{icon}";
        format-icons = {
          "Celluloid" = "";
          "spotify" = "阮";
          "ncspot" = "阮";
          "qutebrowser" = "爵";
          "discord" = "ﭮ";
          "sublimemusic" = "";
          "No players found" = "ﱘ";
        };
      };
      "custom/player" = {
        exec-if = ''
          [[ "$(${playerctl} status)" != "No players found" ]]'';
        exec = ''${playerctl} metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{title}} ({{artist}} - {{album}})"}' '';
        return-type = "json";
        interval = 1;
        max-length = 30;
        format = "{icon} {}";
        format-icons = {
          "Playing" = "契";
          "Paused" = "";
          "Stopped" = "栗";
        };
      };
    }];
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style =
      let inherit (config.colorscheme) colors; in
      ''
        * {
          border: none;
          border-radius: 0px;
          font-family: ${config.fontProfiles.regular.family}, ${config.fontProfiles.monospace.family};
          font-size: 12pt;
          margin: 1px 0;
          padding: 0 8px;
        }

        .modules-right {
          margin-right: -15;
        }

        .modules-left {
          margin-left: -15;
        }

        window#waybar {
          color: #${colors.base05};
          background-color: #${colors.base01};
          border-bottom: 2px solid #${colors.base0C};
          padding: 0;
        }

        #workspaces button {
          margin: 0;
        }
        #workspaces button.visible {
          background-color: #${colors.base00};
          color: #${colors.base04};
        }
        #workspaces button.focused,
        #workspaces button.active {
          background-color: #${colors.base00};
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
          margin-left: 0;
          margin-top: 0;
          margin-bottom: 0;
        }
        #custom-hostname {
          background-color: #${colors.base0B};
          color: #${colors.base00};
          padding-left: 15px;
          padding-right: 18px;
          margin-right: 0;
          margin-top: 0;
          margin-bottom: 0;
        }
      '';
  };
}
