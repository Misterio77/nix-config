{ pkgs, config, nix-colors, hostname, ... }:

with nix-colors.lib { inherit pkgs; };

let
  currentScheme.atlas = "atelier-cave";
  currentScheme.pleione = "pasque";
  currentScheme.merope = "nord";
  currentWallpaper.atlas = "abstract-read-purple-pink.png";
  currentWallpaper.pleione = "cubist-crystal-brown-teal.jpg";
  currentMode = null;
in {
  imports = [ nix-colors.homeManagerModule ];
  home.packages = with pkgs; [ setscheme setwallpaper ];

  colorscheme = if currentScheme != null then
    nix-colors.colorSchemes.${currentScheme.${hostname}}
  else
    colorschemeFromPicture {
      path = config.wallpaper;
      kind = currentMode;
    };

  wallpaper = if currentWallpaper != null then
    "${pkgs.wallpapers}/share/backgrounds/${currentWallpaper.${hostname}}"
  else
    nixWallpaperFromScheme {
      scheme = config.colorscheme;
      width = 2560;
      height = 1080;
      logoScale = 4.5;
    };
}
