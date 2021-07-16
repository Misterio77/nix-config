{ config, pkgs, ... }:

let
  colors = config.colorscheme.colors;
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
in {
  programs.waybar = {
    systemd.enable = true;
    enable = true;
    settings = [
      {
        layer = "top";
        height = 42;
        position = "top";
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "custom/gamemode" "custom/ethminer" "pulseaudio" "cpu" "custom/gpu" "memory" "clock" ];
        modules = {
          clock = {
            format = "{:%d/%m %H:%M}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };
          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };
          memory = {
            format = "{}% ";
          };
          "custom/ethminer" = {
            exec-if = "systemctl --user is-active ethminer";
            exec = "journalctl --user -n 10 -u ethminer | grep '-e \\ m\\ .*' | cut -d ' ' -f12-13";
            interval = 1;
            format = "{} ﲹ";
          }; 
          "custom/gamemode" = {
            exec-if = "gamemoded --status | grep 'is active' -q";
            interval = 2;
            exec = "echo '\n Gamemode is active'";
          };
          "custom/gpu" = {
            exec = "cat /sys/class/drm/card0/device/gpu_busy_percent";
            interval = 2;
            format = "{}% 力";
          };
          pulseaudio = {
            format = "{volume}% {icon}";
            format-muted = "0%  ";
            format-icons = {
              headphone = "";
              headset = "";
              portable = "";
              default = ["" "" ""];
            };
            on-click = "${pavucontrol}";
          };
          "sway/window" = {
            max-length = 50;
          };
          "sway/workspaces" = {
            format = "{icon} {name}";
            format-icons = {
              focused = "綠";
              default = "祿";
            };
          };
        };
      }
    ];
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style = ''
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
        background-color: #${colors.base02};
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

    '';
  };
}
