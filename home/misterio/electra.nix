{pkgs, ...}: {
  imports = [
    ./global
    ./features/desktop/hyprland
  ];
  wallpaper = pkgs.wallpapers.aenami-the-day-you-left;
}
