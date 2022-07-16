{ pkgs, config, inputs, wallpaper, colorscheme, ... }:

let
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) colorschemeFromPicture nixWallpaperFromScheme;
in {
  imports = [ inputs.nix-colors.homeManagerModule ];

  colorscheme =
    if colorscheme != null then
      inputs.nix-colors.colorSchemes.${colorscheme}
    else
      if wallpaper != null then
        colorschemeFromPicture {
          path = config.wallpaper;
          kind = "dark";
        }
      else inputs.nix-colors.colorSchemes.spaceduck;

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

  home.sessionVariables.SCHEME = colorscheme;
}
