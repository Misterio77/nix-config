# This exposes a attrset of wallpaper derivations, each one is fetch from
# imgur. You can manually include new wallpapers in list.nix, or generate them
# from an imgur album using ./from_album.sh
{ pkgs }:
let
  callWallpaper = { name, ext, id, sha256 }: pkgs.callPackage ./wallpaper.nix {
    wallpaper = { inherit name ext id sha256; };
  };
in
builtins.listToAttrs (builtins.map
  (e: {
    name = e.name;
    value = callWallpaper {
      name = e.name;
      ext = e.ext;
      id = e.id;
      sha256 = e.sha256;
    };
  })
  (import ./list.nix))
