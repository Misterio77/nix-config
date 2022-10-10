{ inputs, ... }: {
  imports = [ ./global
    ./features/cli
    ./features/desktop/hyprland
    ./features/trusted
    ./features/rgb
    ./features/games
  ];

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
  colorscheme = inputs.nix-colors.colorSchemes.spaceduck;
}
