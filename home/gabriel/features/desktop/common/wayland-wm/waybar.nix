{
  outputs,
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  commonDeps = with pkgs; [coreutils gnugrep systemd];
  # Function to simplify making waybar outputs
  mkScript = {
    name ? "script",
    deps ? [],
    script ? "",
  }:
    lib.getExe (pkgs.writeShellApplication {
      inherit name;
      text = script;
      runtimeInputs = commonDeps ++ deps;
    });
  # Specialized for JSON outputs
  mkScriptJson = {
    name ? "script",
    deps ? [],
    pre ? "",
    text ? "",
    tooltip ? "",
    alt ? "",
    class ? "",
    percentage ? "",
  }:
    mkScript {
      deps = [pkgs.jq] ++ deps;
      script = ''
        ${pre}
        jq -cn \
          --arg text "${text}" \
          --arg tooltip "${tooltip}" \
          --arg alt "${alt}" \
          --arg class "${class}" \
          --arg percentage "${percentage}" \
          '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
      '';
    };

  swayCfg = config.wayland.windowManager.sway;
  hyprlandCfg = config.wayland.windowManager.hyprland;
in {
  # Let it try to start a few more times
  systemd.user.services.waybar = {
    Unit.StartLimitBurst = 30;
  };
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oa: {
      mesonFlags = (oa.mesonFlags or []) ++ ["-Dexperimental=true"];
    });
    systemd.enable = true;
    settings = {
      primary = {
        exclusive = false;
        passthrough = false;
        height = 40;
        margin = "6";
        position = "top";
        modules-left =
          ["custom/menu"]
          ++ (lib.optionals swayCfg.enable [
            "sway/workspaces"
            "sway/mode"
          ])
          ++ (lib.optionals hyprlandCfg.enable [
            "hyprland/workspaces"
            "hyprland/submap"
          ])
          ++ [
            "custom/currentplayer"
            "custom/player"
          ];

        modules-center = [
          "cpu"
          "custom/gpu"
          "memory"
          "clock"
          "pulseaudio"
          "battery"
          "custom/unread-mail"
          "custom/gpg-agent"
        ];

        modules-right = [
          # "custom/gammastep" TODO: currently broken for some reason
          "custom/rfkill"
          "custom/tailscale-ping"
          "network"
          "tray"
          "custom/hostname"
        ];

        clock = {
          interval = 1;
          format = "{:%d/%m %H:%M:%S}";
          format-alt = "{:%Y-%m-%d %H:%M:%S %z}";
          on-click-left = "mode";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
        };

        cpu = {
          format = "  {usage}%";
        };
        "custom/gpu" = {
          interval = 5;
          exec = mkScript {script = "cat /sys/class/drm/card0/device/gpu_busy_percent";};
          format = "󰒋  {}%";
        };
        memory = {
          format = "  {}%";
          interval = 5;
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "   0%";
          format-icons = {
            headphone = "󰋋";
            headset = "󰋎";
            portable = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = lib.getExe pkgs.pavucontrol;
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰒳";
            deactivated = "󰒲";
          };
        };
        battery = {
          bat = "BAT0";
          interval = 10;
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          onclick = "";
        };
        "sway/window" = {
          max-length = 20;
        };
        network = {
          interval = 3;
          format-wifi = "   {essid}";
          format-ethernet = "󰈁 Connected";
          format-disconnected = "";
          tooltip-format = ''
            {ifname}
            {ipaddr}/{cidr}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
        };
        "custom/tailscale-ping" = {
          interval = 10;
          return-type = "json";
          exec = let
            pingCmd = host: "timeout 2 tailscale ping -c 1 ${host} | tail -1 | cut -d ' ' -f8";
            hosts = lib.attrNames outputs.nixosConfigurations;
            homeMachine = "merope";
            remoteMachine = "alcyone";
          in
            mkScriptJson {
              deps = [pkgs.tailscale];
              # Build variables for each host
              pre = ''
                ${lib.concatStringsSep "\n" (
                  map (host: ''
                    ping_${host}="$(${pingCmd host})" || ping_${host}="Disconnected"
                  '')
                  hosts
                )}
              '';
              # Access a remote machine's and a home machine's ping
              text = "  $ping_${remoteMachine} /   $ping_${homeMachine}";
              # Show pings from all machines
              tooltip = lib.concatStringsSep "\n" (map (host: "${host}: $ping_${host}") hosts);
            };
          format = "{}";
        };
        "custom/menu" = {
          interval = 1;
          return-type = "json";
          exec = mkScriptJson {
            deps = lib.optional hyprlandCfg.enable hyprlandCfg.package;
            text = "";
            tooltip = ''$(grep /etc/os-release PRETTY_NAME | cut -d '"' -f2)'';
            class = let
              isFullScreen =
                if hyprlandCfg.enable
                then "hyprctl activewindow -j | jq -e '.fullscreen' &>/dev/null"
                else "false";
            in "$(if ${isFullScreen}; then echo fullscreen; fi)";
          };
        };
        "custom/hostname" = {
          exec = mkScript {script = ''echo "$USER@$HOSTNAME"'';};
          on-click = mkScript {script = "systemctl --user restart waybar";};
        };
        "custom/unread-mail" = {
          interval = 5;
          return-type = "json";
          exec = mkScriptJson {
            deps = [pkgs.findutils pkgs.procps];
            pre = ''
              count=$(find ~/Mail/*/Inbox/new -type f | wc -l)
              if pgrep mbsync &>/dev/null; then
                status="syncing"
              else
                if [ "$count" == "0" ]; then
                  status="read"
                else
                  status="unread"
                fi
              fi
            '';
            text = "$count";
            alt = "$status";
          };
          format = "{icon}  ({})";
          format-icons = {
            "read" = "󰇯";
            "unread" = "󰇮";
            "syncing" = "󰁪";
          };
        };
        "custom/gpg-agent" = {
          interval = 2;
          return-type = "json";
          exec = mkScriptJson {
            deps = [pkgs.procps pkgs.gnupg];
            pre = let
              isUnlocked = "pgrep 'gpg-agent' &> /dev/null && gpg-connect-agent 'scd getinfo card_list' /bye | grep SERIALNO -q";
            in ''status=$(${isUnlocked} && echo "unlocked" || echo "locked")'';
            alt = "$status";
            tooltip = "GPG is $status";
          };
          format = "{icon}";
          format-icons = {
            "locked" = "";
            "unlocked" = "";
          };
        };
        "custom/gammastep" = {
          interval = 5;
          return-type = "json";
          exec = mkScriptJson {
            deps = [pkgs.findutils];
            pre = ''
              if unit_status="$(systemctl --user is-active gammastep)"; then
                period="$(journalctl --user -u gammastep.service -g 'Period: ' | tail -1 | cut -d ':' -f6 | xargs)"
                status="$unit_status ($period)"
              else
                status="$unit_status"
              fi
            '';
            alt = "\${status:-inactive}";
            tooltip = "Gammastep is $status";
          };
          format = "{icon}";
          format-icons = {
            "activating" = "󰁪 ";
            "deactivating" = "󰁪 ";
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
          on-click = mkScript {
            script = ''
              if systemctl --user is-active gammastep; then
                systemctl --user stop gammastep
              else
                systemctl --user start gammastep
              fi
            '';
          };
        };
        "custom/currentplayer" = {
          interval = 2;
          return-type = "json";
          exec = mkScriptJson {
            deps = [pkgs.playerctl];
            pre = ''
              player="$(playerctl status -f "{{playerName}}" 2>/dev/null || echo "No player active" | cut -d '.' -f1)"
              count="$(playerctl -l 2>/dev/null | wc -l)"
              if ((count > 1)); then
                more=" +$((count - 1))"
              else
                more=""
              fi
            '';
            alt = "$player";
            tooltip = "$player ($count available)";
            text = "$more";
          };
          format = "{icon}{}";
          format-icons = {
            "No player active" = " ";
            "Celluloid" = "󰎁 ";
            "spotify" = "󰓇 ";
            "ncspot" = "󰓇 ";
            "qutebrowser" = "󰖟 ";
            "firefox" = " ";
            "discord" = " 󰙯 ";
            "sublimemusic" = " ";
            "kdeconnect" = "󰄡 ";
            "chromium" = " ";
          };
        };
        "custom/rfkill" = {
          interval = 1;
          exec-if = mkScript {
            deps = [pkgs.util-linux];
            script = "rfkill | grep '\<blocked\>'";
          };
        };
        "custom/player" = {
          exec-if = mkScript {
            deps = [pkgs.playerctl];
            script = "playerctl status 2>/dev/null";
          };
          exec = let
            format = ''{"text": "{{title}} - {{artist}}", "alt": "{{status}}", "tooltip": "{{title}} - {{artist}} ({{album}})"}'';
          in
            mkScript {
              deps = [pkgs.playerctl];
              script = "playerctl metadata --format '${format}' 2>/dev/null";
            };
          return-type = "json";
          interval = 2;
          max-length = 30;
          format = "{icon} {}";
          format-icons = {
            "Playing" = "󰐊";
            "Paused" = "󰏤 ";
            "Stopped" = "󰓛";
          };
          on-click = mkScript {
            deps = [pkgs.playerctl];
            script = "playerctl play-pause";
          };
        };
      };
    };
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style = let
      inherit (inputs.nix-colors.lib.conversions) hexToRGBString;
      inherit (config.colorscheme) colors;
      toRGBA = color: opacity: "rgba(${hexToRGBString "," (lib.removePrefix "#" color)},${opacity})";
    in
      /*
      css
      */
      ''
        * {
          font-family: ${config.fontProfiles.regular.family}, ${config.fontProfiles.monospace.family};
          font-size: 12pt;
          padding: 0;
          margin: 0 0.4em;
        }

        window#waybar {
          padding: 0;
          border-radius: 0.5em;
          background-color: ${toRGBA colors.surface "0.7"};
          color: ${colors.on_surface};
        }
        .modules-left {
          margin-left: -0.65em;
        }
        .modules-right {
          margin-right: -0.65em;
        }

        #workspaces button {
          background-color: ${colors.surface};
          color: ${colors.on_surface};
          padding-left: 0.4em;
          padding-right: 0.4em;
          margin-top: 0.15em;
          margin-bottom: 0.15em;
        }
        #workspaces button.hidden {
          background-color: ${colors.surface};
          color: ${colors.on_surface_variant};
        }
        #workspaces button.focused,
        #workspaces button.active {
          background-color: ${colors.tertiary};
          color: ${colors.on_tertiary};
        }

        #clock {
          padding-right: 1em;
          padding-left: 1em;
          border-radius: 0.5em;
        }

        #custom-menu {
          background-color: ${colors.surface_bright};
          padding-right: 1.5em;
          padding-left: 1em;
          margin-right: 0;
          border-radius: 0.5em;
        }
        #custom-menu.fullscreen {
          background-color: ${colors.primary};
          color: ${colors.on_primary};
        }
        #custom-hostname {
          padding-right: 1em;
          padding-left: 1em;
          margin-left: 0;
          border-radius: 0.5em;
        }
        #custom-currentplayer {
          padding-right: 0;
        }
        #tray {
          color: ${colors.on_surface};
        }
        #custom-gpu, #cpu, #memory {
          margin-left: 0.05em;
          margin-right: 0.55em;
        }
      '';
  };
}
