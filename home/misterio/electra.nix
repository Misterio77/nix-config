{ inputs, pkgs, ... }: {
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/desktop/wireless
    ./features/trusted
  ];

  wallpaper = (import ./wallpapers).aenami-lunar;
  colorscheme = inputs.nix-colors.colorschemes.paraiso;

  monitors = [{
    name = "eDP-1";
    width = 1920;
    height = 1080;
    isPrimary = true;
    workspace = "1";
  }];
  wayland.windowManager.hyprland.nvidiaPatches = true;
}
