{pkgs, lib, ...}: {
  imports = [
    ./global
    ./features/desktop/hyprland
  ];
  home.persistence."/persist/home/misterio" = lib.mkForce {};
  home.username = "gabriel";

  programs.fish.interactiveShellInit = /* fish */ ''
    set -p LD_LIBRARY_PATH (${lib.getExe pkgs.inputs.nix-gl.nixGLIntel} printenv LD_LIBRARY_PATH)
  '';

  wallpaper = pkgs.wallpapers.aenami-the-day-you-left;
}
