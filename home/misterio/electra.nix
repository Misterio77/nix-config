{ inputs, pkgs, ... }:
let
  dark-mode = inputs.dark-mode.value;
  inherit (inputs.nix-colors.colorSchemes) silk-dark silk-light;
in
{
  imports = [
    ./global
    ./features/desktop/wireless
    ./features/desktop/hyprland
    ./features/pass
  ];

  wallpaper = (import ./wallpapers).aenami-wait;
  colorscheme = if dark-mode then silk-dark else silk-light;

  monitors = [{
    name = "eDP-1";
    width = 1920;
    height = 1080;
    workspace = "1";
    x = 0;
  }];

  # programs.git.userEmail = "gabriel@zoocha.com";
}
