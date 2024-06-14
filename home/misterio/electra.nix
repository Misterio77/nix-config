{pkgs, lib, ...}: {
  imports = [
    ./global
    ./features/desktop/hyprland
  ];
  home.persistence."/persist/home/misterio" = lib.mkForce {};
  home.username = "gabriel";
  wallpaper = pkgs.wallpapers.aenami-the-day-you-left;
}
