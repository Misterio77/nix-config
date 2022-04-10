# This exposes a attrset of wallpaper derivations, each one is fetch from
# imgur. You can manually include new wallpapers in list.nix, or generate them
# from an imgur album using ./from_album.sh
{ pkgs }:
builtins.listToAttrs (builtins.map
  (wallpaper: {
    inherit (wallpaper) name;
    value = pkgs.callPackage ./wallpaper.nix { inherit wallpaper; };
  })
  (import ./list.nix))
