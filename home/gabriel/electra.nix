{pkgs, lib, config, ...}: let
  nixGL = pkgs.inputs.nix-gl.nixGLIntel;
in {
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/pass
  ];
  home.persistence."/persist/${config.home.homeDirectory}" = lib.mkForce {};
  home.username = "gabriel";
  home.packages = [nixGL];

  targets.genericLinux.enable = true;
  programs.git.includes = [{ path = "~/.config/git/local.conf"; }];

  monitors = [{
    name = "eDP-1";
    width = 1920;
    height = 1080;
    workspace = "1";
    primary = true;
  }];
  # Green
  wallpaper = pkgs.wallpapers.aenami-northern-lights;
  colorscheme.type = "rainbow";
}
