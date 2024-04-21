{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/rgb
    ./features/productivity
    ./features/pass
    ./features/games
    ./features/games/star-citizen.nix
    ./features/games/yuzu.nix
    ./features/music
  ];

  wallpaper = lib.mkDefault pkgs.wallpapers.abstract-cyan-purple;
  colorscheme.source = config.wallpaper;
  specialisation = lib.mkForce (
    lib.mapAttrs (n: w: {configuration.wallpaper = w;}) {
      inherit
        (pkgs.wallpapers)
        abstract-cyan-purple
        aurora-borealis-water-mountain
        mountain-pink-purple
        mountain-yellow-sunset
        nebula-purple-gold
        plains-gold-field
        ;
    }
  );

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
