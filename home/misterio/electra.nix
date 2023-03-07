{ inputs, pkgs, ... }: {
  imports = [
    ./global
    ./features/desktop/wireless
    ./features/desktop/hyprland
    ./features/pass
  ];

  wallpaper = (import ./wallpapers).aenami-7pm;
  colorscheme = inputs.nix-colors.colorschemes.pasque;

  monitors = [{
    name = "eDP-1";
    width = 1920;
    height = 1080;
    hasBar = true;
    workspace = "1";
    x = 0;
  }];

  # programs.git.userEmail = "gabriel@zoocha.com";
}
