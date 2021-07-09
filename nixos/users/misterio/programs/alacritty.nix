{ config, pkgs, lib, ... }:

let 
  colors = config.colorscheme.colors;
in { 
  nixpkgs.overlays = [
    (self: super: {
      alacritty = super.alacritty.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "ncfavier";
          repo = "alacritty";
          rev = "8b82ea89e853889e0294635835806e13010bd8f0";
          sha256 = "0358jc0axwk4g33z70pv6glkjzwpc4qx6555xamk5pxp4498j830";
        };
        cargoDeps = oldAttrs.cargoDeps.overrideAttrs (_: {
          inherit src;
          outputHash = "04pd3v586y1zpqqslwqqs4xxhp3aghkkh0rqhcrdnahb9i40fql3";
        });
      });
    })
  ];
  programs.alacritty = {
    enable = true;
    settings = {
      import = [
        "~/.config/alacritty/colors.yml"
      ];
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
      #colors = {
      #  primary = {
      #    background = "${colors.base00}";
      #    foreground = "${colors.base05}";
      #  };
      #  cursor = {
      #    text = "${colors.base00}";
      #    cursor = "${colors.base05}";
      #  };
      #  normal = {
      #    black = "${colors.base00}";
      #    red = "${colors.base08}";
      #    green = "${colors.base0B}";
      #    yellow = "${colors.base0A}";
      #    blue = "${colors.base0D}";
      #    magenta = "${colors.base0E}";
      #    cyan = "${colors.base0C}";
      #    white = "${colors.base05}";
      #  };
      #  bright = {
      #    black = "${colors.base03}";
      #    red = "${colors.base09}";
      #    green = "${colors.base01}";
      #    yellow = "${colors.base02}";
      #    blue = "${colors.base04}";
      #    magenta = "${colors.base06}";
      #    cyan = "${colors.base0F}";
      #    white = "${colors.base07}";
      #  };
      #};
    };
  };
}
