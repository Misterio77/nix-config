{ config, pkgs, ... }:

let
  colors = config.colorscheme.colors;
  wezterm-xterm = pkgs.writeShellScriptBin "xterm" ''
    if [ "$1" = "-e" ]; then
      shift 1
    fi
    ${pkgs.wezterm}/bin/wezterm start -- "$SHELL" -ic "$*"
  '';
in {
  home.packages = [ pkgs.wezterm wezterm-xterm ];
  home.sessionVariables = { TERMINAL = "wezterm"; };
  xdg.configFile."wezterm/wezterm.lua".text = ''
    local wezterm = require 'wezterm';
    return {
      font = wezterm.font("${config.fontProfiles.monospace.family}"),
      enable_tab_bar = false,
      window_padding = {
        left = 24,
        right = 24,
        top = 26,
        bottom = 26,
      },
      window_close_confirmation = "NeverPrompt",
      default_cursor_style = "SteadyBar",
      colors = {
        background = "#${colors.base00}",
        foreground = "#${colors.base05}",
        cursor_bg = "#${colors.base05}",
        cursor_fg = "#${colors.base00}",
        ansi = {
          "#${colors.base00}",
          "#${colors.base08}",
          "#${colors.base0B}",
          "#${colors.base0A}",
          "#${colors.base0D}",
          "#${colors.base0E}",
          "#${colors.base0C}",
          "#${colors.base05}",
        },
        brights = {
          "#${colors.base03}",
          "#${colors.base08}",
          "#${colors.base0B}",
          "#${colors.base0A}",
          "#${colors.base0D}",
          "#${colors.base0E}",
          "#${colors.base0C}",
          "#${colors.base07}",
        },
        indexed_colors = {
          [16] = "#${colors.base09}",
          [17] = "#${colors.base0F}",
          [18] = "#${colors.base01}",
          [19] = "#${colors.base02}",
          [20] = "#${colors.base04}",
          [21] = "#${colors.base06}",
        };
      }
    }
  '';
}
