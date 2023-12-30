{ inputs, lib, pkgs, ... }: let
  inherit (inputs.nix-colors) colorSchemes;
in {
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/desktop/wireless
    ./features/productivity
    ./features/pass
    ./features/games
  ];

  wallpaper = pkgs.wallpapers.aenami-dawn;
  colorscheme = lib.mkDefault colorSchemes.atelier-heath;
  specialisation = {
    light.configuration.colorscheme = colorSchemes.atelier-heath-light;
  };

  monitors = [{
    name = "eDP-1";
    width = 1920;
    height = 1080;
    workspace = "1";
    primary = true;
  }];
}
