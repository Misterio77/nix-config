{ config, pkgs, ... }:

let
  inherit (config) colorscheme;
  inherit (colorscheme) colors;
in
{
  programs.wezterm = {
    enable = true;
    colorSchemes = {
      "${colorscheme.slug}" = {
        foreground = "#${colors.base05}";
        background = "#${colors.base00}";

        ansi = [
          "#${colors.base08}"
          "#${colors.base09}"
          "#${colors.base0A}"
          "#${colors.base0B}"
          "#${colors.base0C}"
          "#${colors.base0D}"
          "#${colors.base0E}"
          "#${colors.base0F}"
        ];
        brights = [
          "#${colors.base00}"
          "#${colors.base01}"
          "#${colors.base02}"
          "#${colors.base03}"
          "#${colors.base04}"
          "#${colors.base05}"
          "#${colors.base06}"
          "#${colors.base07}"
        ];
        cursor_fg = "#${colors.base00}";
        cursor_bg = "#${colors.base05}";
        selection_fg = "#${colors.base00}";
        selection_bg = "#${colors.base05}";
      };
    };
    extraConfig = /* lua */ ''
      return {
        font = wezterm.font("${config.fontProfiles.monospace.family}"),
        font_size = 12.0,
        color_scheme = "${colorscheme.slug}",
        hide_tab_bar_if_only_one_tab = true,
        window_close_confirmation = "NeverPrompt",
        set_environment_variables = {
          TERM = 'wezterm',
        },
      }
    '';
  };
}
