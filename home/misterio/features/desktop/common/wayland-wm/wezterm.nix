{
  config,
  pkgs,
  ...
}: let
  inherit (config) colorscheme;
  inherit (colorscheme) colors;
in {
  programs.wezterm = {
    enable = true;
    colorSchemes = {
      "${colorscheme.slug}" = {
        foreground = "#${colors.base04}";
        background = "#${colors.base00}";

        ansi = [
          "#${colors.base01}"
          "#${colors.base08}"
          "#${colors.base0B}"
          "#${colors.base0A}"
          "#${colors.base0D}"
          "#${colors.base0F}"
          "#${colors.base0C}"
          "#${colors.base06}"
        ];
        brights = [
          "#${colors.base00}"
          "#${colors.base09}"
          "#${colors.base02}"
          "#${colors.base03}"
          "#${colors.base04}"
          "#${colors.base0E}"
          "#${colors.base05}"
          "#${colors.base07}"
        ];

        cursor_bg = "#${colors.base04}";
        cursor_border = "#${colors.base04}";
        cursor_fg = "#${colors.base01}";
        selection_fg = "#${colors.base00}";
        selection_bg = "#${colors.base01}";
      };
    };
    extraConfig =
      /*
      lua
      */
      ''
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
