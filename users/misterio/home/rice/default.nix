{ pkgs, config, inputs, hostname, wallpaper, colorscheme, ... }:

with inputs.nix-colors.lib { inherit pkgs; };
{
  imports = [ inputs.nix-colors.homeManagerModule ];

  colorscheme =
    if colorscheme != null then
      inputs.nix-colors.colorSchemes.${colorscheme}
    else
      colorschemeFromPicture {
        path = config.wallpaper;
        kind = currentMode;
      };

  wallpaper =
    if wallpaper != null then
      pkgs.wallpapers.${wallpaper}
    else
      nixWallpaperFromScheme {
        scheme = config.colorscheme;
        width = 2560;
        height = 1080;
        logoScale = 4.5;
      };
}
