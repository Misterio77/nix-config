{ pkgs, ... }:
let
  iosevka-term = pkgs.iosevka.override {
    set = "iosevka-term";
    privateBuildPlan = {
      family = "Iosevka Term";
      spacing = "term";
      serifs = "slab";
      no-cv-ss = true;
      variants = {
        design = {
          cyrl-ef = "cursive";
          brace = "curly-flat-boundary";
          number-sign = "slanted-open";
          bar = "natural-slope";
          ascii-grave = "straight";
        };
      };
      ligations = {
        inherits = "dlig";
      };
      widths.normal = {
        shape = 600;
        menu = 5;
        css = "normal";
      };
    };
  };
  iosevka-etoile = pkgs.iosevka.override {
    set = "iosevka-etoile";
    privateBuildPlan = {
      family = "Iosevka Etoile";
      spacing = "quasi-proportional";
      serifs = "slab";
      variants = {
        design = {
          at = "fourfold";
          capital-w = "straight-flat-top";
          f = "flat-hook-serifed";
          j = "flat-hook-serifed";
          t = "flat-hook";
          w = "straight-flat-top";
        };
        italic = {
          f = "flat-hook-tailed";
        };
      };
      widths.normal = {
        shape = 600;
        menu = 5;
        css = "normal";
      };
    };
  };
in
{
  fontProfiles = {
    enable = true;
    monospace = {
      family = "Fira Code Nerd Font";
      package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
    };
    regular = {
      family = "Fira Sans";
      package = pkgs.fira;
    };
  };
}
