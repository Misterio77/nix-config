{ pkgs, config, nix-colors, ... }:

with nix-colors.lib { inherit pkgs; };

let
  currentWallpaper = import ./current-wallpaper.nix;
  currentMode = import ./current-mode.nix;
  currentScheme = import ./current-scheme.nix;
in {
  colorscheme = if currentScheme != null
    then nix-colors.colorSchemes.${currentScheme}
    else colorschemeFromPicture {
      path = config.wallpaper;
      kind = currentMode;
    };

  wallpaper = if currentWallpaper != null
    then "${pkgs.wallpapers}/share/backgrounds/${currentWallpaper}"
    else nixWallpaperFromScheme {
      scheme = config.colorscheme;
      width = 2560;
      height = 1080;
      logoScale = 4.5;
    };
}
