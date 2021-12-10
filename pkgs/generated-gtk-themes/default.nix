{ pkgs, nix-colors }:

with nix-colors.lib { inherit pkgs; };

builtins.mapAttrs
  (name: value:
    gtkThemeFromScheme {
      scheme = value;
    })
  nix-colors.colorSchemes
