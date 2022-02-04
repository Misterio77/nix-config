{ pkgs, config, inputs, hostname, ... }:

with inputs.nix-colors.lib { inherit pkgs; };

let
  currentScheme.atlas = "spaceduck";
  currentScheme.pleione = "paraiso";
  currentScheme.merope = "nord";
  currentScheme.maia = "ashes";
  currentWallpaper.atlas = "desert-dunes";
  currentWallpaper.pleione = "cyberpunk-city-red";
  currentMode = null;
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
      pkgs.wallpapers.${currentWallpaper.${hostname}}
    else
      nixWallpaperFromScheme {
        scheme = config.colorscheme;
        width = 2560;
        height = 1080;
        logoScale = 4.5;
      };
}
