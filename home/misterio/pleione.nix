{ inputs, pkgs, ... }:
let
  dark-mode = inputs.dark-mode.value;
  inherit (inputs.nix-colors.colorSchemes) atelier-heath atelier-heath-light;
in
{
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/desktop/wireless
    ./features/productivity
    ./features/pass
    ./features/games
  ];

  wallpaper = (import ./wallpapers).aenami-lunar;
  colorscheme = if dark-mode then atelier-heath else atelier-heath-light;

  monitors = [{
    name = "eDP-1";
    width = 1920;
    height = 1080;
    workspace = "1";
  }];
}
