{ inputs, pkgs, config, ... }:
let
  inherit (pkgs) wallpapers;
  inherit (inputs.nix-colors) colorSchemes;
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) colorschemeFromPicture nixWallpaperFromScheme;
  emerald-light = {
    author = "Gabriel Fontes";
    slug = "emerald-light";
    name = "Emerald Light";
    colors = {
      base00 = "#faf0f0";
      base01 = "#f6dedd";
      base02 = "#f5b8bb";
      base03 = "#e29397";
      base04 = "#d48d92";
      base05 = "#011a17";
      base06 = "#02332c";
      base07 = "#044038";
      base08 = "#aa0f0f";
      base09 = "#aa3824";
      base0A = "#9c5c2b";
      base0B = "#0d7830";
      base0C = "#09665a";
      base0D = "#0d5762";
      base0E = "#532c68";
      base0F = "#501724";
    };
  };
  emerald-dark = {
    author = "Gabriel Fontes";
    slug = "emerald-dark";
    name = "Emerald Dark";
    colors = {
      base00 = "#112127";
      base01 = "#1c2e31";
      base02 = "#1e3739";
      base03 = "#3e5959";
      base04 = "#58756e";
      base05 = "#d1acab";
      base06 = "#b35e65";
      base07 = "#ab4a4f";
      base08 = "#e96c6c";
      base09 = "#f19282";
      base0A = "#e5ba79";
      base0B = "#6ac087";
      base0C = "#67e3d2";
      base0D = "#64b8c5";
      base0E = "#bb7ddc";
      base0F = "#e66b88";
    };
  };
in
{
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/trusted
    ./features/rgb
    ./features/games
  ];

  wallpaper = wallpapers.aenami-bright-planet;
  colorscheme = emerald-dark;

  # My setup's layout:
  #  ------   -----   ------
  # | DP-3 | | DP-1| | DP-2 |
  #  ------   -----   ------
  monitors = [
    {
      name = "DP-3";
      isSecondary = true;
      width = 1920;
      height = 1080;
      x = 0;
      workspace = "3";
      enabled = true;
    }
    {
      name = "DP-1";
      width = 2560;
      height = 1080;
      refreshRate = 75;
      x = 1920;
      workspace = "1";
      enabled = true;
    }
    {
      name = "DP-2";
      isSecondary = true;
      width = 1920;
      height = 1080;
      x = 4480;
      workspace = "2";
      enabled = true;
    }
  ];
}
