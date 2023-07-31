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
      primary = true;
    }
  ];

  # programs.git.userEmail = "gabriel@zoocha.com";
}
