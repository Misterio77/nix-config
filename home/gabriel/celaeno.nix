{pkgs, ...}: {
  imports = [./global];
  # Salmon
  wallpaper = pkgs.inputs.themes.wallpapers.abstract-salmon-blue;
}
