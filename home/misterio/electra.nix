{pkgs, lib, ...}: {
  imports = [
    ./global
    ./features/desktop/hyprland
  ];
  home.persistence."/persist/home/misterio" = lib.mkForce {};
  home.username = "gabriel";
  home.packages = [pkgs.inputs.nix-gl.nixGLIntel];
  wallpaper = pkgs.wallpapers.aenami-the-day-you-left;
}
