{ inputs, outputs, ... }:
{
  imports = [
    ./global
    ./features/desktop/wireless
    ./features/desktop/hyprland
    ./features/pass
  ];

  wallpaper = outputs.wallpapers.aenami-wait;
  colorscheme = inputs.nix-colors.colorSchemes.silk-dark;

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      workspace = "3";
      x = 0;
    }
    {
      name = "DP-2";
      width = 1920;
      height = 1080;
      workspace = "1";
      x = 1920;
    }
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      workspace = "2";
      x = 3840;
    }
  ];

  # programs.git.userEmail = "gabriel@zoocha.com";
}
