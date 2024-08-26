{config, ...}: let
  inherit (config.colorscheme) colors;
in {
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      font = "${config.fontProfiles.regular.name} ${toString config.fontProfiles.regular.size}";
      recolor = true;
      default-bg = "${colors.surface}";
      default-fg = "${colors.surface_bright}";
      statusbar-bg = "${colors.surface_container}";
      statusbar-fg = "${colors.on_surface_variant}";
      inputbar-bg = "${colors.surface}";
      inputbar-fg = "${colors.on_secondary}";
      notification-bg = "${colors.surface}";
      notification-fg = "${colors.on_secondary}";
      notification-error-bg = "${colors.error}";
      notification-error-fg = "${colors.on_error}";
      notification-warning-bg = "${colors.error}";
      notification-warning-fg = "${colors.on_error}";
      highlight-color = "${colors.tertiary}";
      highlight-active-color = "${colors.secondary}";
      completion-bg = "${colors.surface_bright}";
      completion-fg = "${colors.on_surface}";
      completions-highlight-bg = "${colors.secondary}";
      completions-highlight-fg = "${colors.on_secondary}";
      recolor-lightcolor = "${colors.surface}";
      recolor-darkcolor = "${colors.inverse_surface}";
    };
  };
}
