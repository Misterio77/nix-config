# This "package" is not used in my install, this file is meant for building through the flake on CI (for caching gtk themes).
{ pkgs, nix-colors }:

with nix-colors.lib { inherit pkgs; };

builtins.mapAttrs
  (name: value:
    gtkThemeFromScheme {
      scheme = value;
    })
  nix-colors.colorSchemes
