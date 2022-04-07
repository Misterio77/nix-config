{ pkgs, ... }:
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
