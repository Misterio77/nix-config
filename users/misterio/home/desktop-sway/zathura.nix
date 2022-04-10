{ config, ... }:
let inherit (config.colorscheme) colors;
in {
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      font = "${config.fontProfiles.regular.family} 12";
      recolor = true;
      default-bg = "#${colors.base00}";
      default-fg = "#${colors.base01}";
      statusbar-bg = "#${colors.base02}";
      statusbar-fg = "#${colors.base04}";
      inputbar-bg = "#${colors.base00}";
      inputbar-fg = "#${colors.base07}";
      notification-bg = "#${colors.base00}";
      notification-fg = "#${colors.base07}";
      notification-error-bg = "#${colors.base00}";
      notification-error-fg = "#${colors.base08}";
      notification-warning-bg = "#${colors.base00}";
      notification-warning-fg = "#${colors.base08}";
      highlight-color = "#${colors.base0A}";
      highlight-active-color = "#${colors.base0D}";
      completion-bg = "#${colors.base01}";
      completion-fg = "#${colors.base05}";
      completions-highlight-bg = "#${colors.base0D}";
      completions-highlight-fg = "#${colors.base07}";
      recolor-lightcolor = "#${colors.base00}";
      recolor-darkcolor = "#${colors.base06}";
    };
  };
}
