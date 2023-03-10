{ inputs, pkgs, ... }: {
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/rgb
    ./features/productivity
    ./features/pass
    ./features/games
    ./features/music
  ];

  wallpaper = (import ./wallpapers).aenami-bright-planet;
  colorscheme = inputs.nix-colors.colorschemes.material-palenight;

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
    }
    {
      name = "DP-1";
      width = 2560;
      height = 1080;
      hasBar = true;
      refreshRate = 75;
      x = 1920;
      workspace = "1";
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
