{
  pkgs,
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
  ];

  # Purple
  wallpaper = pkgs.wallpapers.mountain-nebula-purple-pink;

  #  ------   -----   ------
  # | DP-3 | | DP-1| | DP-2 |
  #  ------   -----   ------
  monitors = [
    {
      name = "DP-1";
      width = 2560;
      height = 1080;
      x = 0;
      workspace = "1";
      primary = true;
    }
    {
      name = "DP-2";
      width = 1920;
      height = 1080;
      x = 2560;
      workspace = "2";
    }
  ];
}
