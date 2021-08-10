{ config, pkgs, lib, ... }:

let 
  colors = config.colorscheme.colors;
in { 
  # TODO: remove when https://github.com/alacritty/alacritty/pull/5313 is merged
  nixpkgs.overlays = [
    (self: super: {
      alacritty = super.alacritty.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "ncfavier";
          repo = "alacritty";
          rev = "5f392c2cb516a5ea198ebb48754c7c42157d21b3";
          sha256 = "0358jc0axwk4g33z70pv6glkjzwpc4qx6555xamk5pxp4498j831";
        };
        cargoDeps = oldAttrs.cargoDeps.overrideAttrs (_: {
          inherit src;
          outputHash = "04pd3v586y1zpqqslwqqs4xxhp3aghkkh0rqhcrdnahb9i40fql1";
        });
      });
    })
  ];
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 12.0;
        normal.family = "FiraCode Nerd Font";
      };
      window = {
        padding = {
          x = 20;
          y = 20;
        };
        dynamic_title = true;
      };
      colors = {
        primary = {
          background = "#${colors.base00}";
          foreground = "#${colors.base05}";
        };
        cursor = {
          text = "#${colors.base00}";
          cursor = "#${colors.base05}";
        };
        normal = {
          black = "#${colors.base00}";
          red = "#${colors.base08}";
          green = "#${colors.base0B}";
          yellow = "#${colors.base0A}";
          blue = "#${colors.base0D}";
          magenta = "#${colors.base0E}";
          cyan = "#${colors.base0C}";
          white = "#${colors.base05}";
        };
        bright = {
          black = "#${colors.base03}";
          red = "#${colors.base08}";
          green = "#${colors.base0B}";
          yellow = "#${colors.base0A}";
          blue = "#${colors.base0D}";
          magenta = "#${colors.base0E}";
          cyan = "#${colors.base0C}";
          white = "#${colors.base07}";
        };
        indexed_colors = [
          {
            index = 16;
            color = "#${colors.base09}";
          }
          {
            index = 17;
            color = "#${colors.base0F}";
          }
          {
            index = 18;
            color = "#${colors.base01}";
          }
          {
            index = 19;
            color = "#${colors.base02}";
          }
          {
            index = 20;
            color = "#${colors.base04}";
          }
          {
            index = 21;
            color = "#${colors.base06}";
          }
        ];
      };
    };
  };
}
