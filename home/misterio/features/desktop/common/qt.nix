{ pkgs, config, ... }:
{
  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "gtk2";
      package = pkgs.qt6Packages.qt6gtk2;
    };
  };
}
