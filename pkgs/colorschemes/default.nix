{
  wallpapers,
  pkgs,
  ...
}: let
  generator = import ./generator.nix {inherit pkgs;};
in
  pkgs.lib.mapAttrs (_: v: generator v.name v) wallpapers
