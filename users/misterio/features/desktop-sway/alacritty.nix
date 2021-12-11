{ config, pkgs, ... }:

let colors = config.colorscheme.colors;
in {
  home.sessionVariables = {
    TERMINAL = "alacritty";
  };
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty-ligatures;
    settings = {
      live_config_reload = false;
      font = {
        size = 12.0;
        normal.family = "FiraCode Nerd Font";
      };
      window = {
        padding = {
          x = 24;
          y = 26;
        };
        dynamic_title = true;
      };
      colors = {
        primary = {
          background = "#${colors.base00}";
          foreground = "#${colors.base05}";
        };
      };
    };
  };
}
