{ pkgs, config, inputs, hostname, ... }:

with inputs.nix-colors.lib { inherit pkgs; };

let
  currentScheme.atlas = "atelier-cave-light";
  currentScheme.pleione = "silk-light";
  currentScheme.merope = "nord";
  currentScheme.maia = "pasque";
  currentWallpaper.atlas = "abstract-red-purple-pink";
  currentWallpaper.pleione = "cubist-crystal-brown-teal";
  currentMode = null;
  wallpaperPath = name: "${pkgs.wallpapers.${currentWallpaper.${hostname}}}/share/backgrounds/${currentWallpaper.${hostname}}";
in
{
  imports = [ inputs.nix-colors.homeManagerModule ];
  home.packages = with pkgs; [ setscheme setwallpaper ];

  colorscheme =
    if currentScheme.${hostname} != null then
      inputs.nix-colors.colorSchemes.${currentScheme.${hostname}}
    else
      colorschemeFromPicture {
        path = config.wallpaper;
        kind = currentMode;
      };

  wallpaper =
    if currentWallpaper.${hostname} != null then
      wallpaperPath currentWallpaper.${hostname}
    else
      nixWallpaperFromScheme {
        scheme = config.colorscheme;
        width = 2560;
        height = 1080;
        logoScale = 4.5;
      };
}
