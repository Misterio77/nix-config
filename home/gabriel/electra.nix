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

  # programs.fish.interactiveShellInit = /* fish */ ''
  #   set -p LD_LIBRARY_PATH (${lib.getExe nixGL} printenv LD_LIBRARY_PATH)
  #   set -p LIBGL_DRIVERS_PATH (${lib.getExe nixGL} printenv LIBGL_DRIVERS_PATH)
  #   set -p LIBVA_DRIVERS_PATH (${lib.getExe nixGL} printenv LIBVA_DRIVERS_PATH)
  # '';

  targets.genericLinux.enable = true;

  programs.git = {
    userEmail = "gabriel.fontes@luizalabs.com";
    # Not adding my work email to my gpg, thanks
    extraConfig.commit.gpgSign = false;
  };

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
