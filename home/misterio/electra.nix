{pkgs, lib, ...}: {
  imports = [
    ./global
    ./features/desktop/hyprland
  ];
  home.persistence."/persist/home/misterio" = lib.mkForce {};
  wallpaper = pkgs.wallpapers.aenami-the-day-you-left;
}
