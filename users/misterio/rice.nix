{ pkgs, config, nix-colors, ... }:

with nix-colors.lib { inherit pkgs; };

let
  currentScheme = "spaceduck";
  currentWallpaper = "cubist-crystal-brown-teal.jpg";
  currentMode = null;
in {
  imports = [ nix-colors.homeManagerModule ];
  home.packages = with pkgs; [
    setscheme
    setwallpaper
  ];

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
