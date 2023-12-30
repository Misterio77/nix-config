{ inputs, lib, pkgs, ... }: let
  inherit (inputs.nix-colors) colorSchemes;
in {
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/rgb
    ./features/productivity
    ./features/pass
    ./features/games
    ./features/games/star-citizen.nix
    ./features/music
  ];

  wallpaper = pkgs.wallpapers.aurora-borealis-water-mountain;
  colorscheme = lib.mkDefault colorSchemes.tokyo-city-terminal-dark;
  specialisation = {
    light.configuration.colorscheme = colorSchemes.tokyo-city-terminal-light;
  };

  #  ------   -----   ------
  # | DP-3 | | DP-1| | DP-2 |
  #  ------   -----   ------
  monitors = [
    {
      name = "DP-3";
      width = 1920;
      height = 1080;
      x = 0;
      workspace = "3";
      enabled = false;
    }
    {
      name = "DP-1";
      width = 2560;
      height = 1080;
      x = 1920;
      workspace = "1";
      primary = true;
    }
    {
      name = "DP-2";
      width = 1920;
      height = 1080;
      x = 4480;
      workspace = "2";
    }
  ];
}
