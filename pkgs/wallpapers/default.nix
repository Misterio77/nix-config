{ lib, fetchurl }:
lib.listToAttrs (map
  (wallpaper: {
    inherit (wallpaper) name;
    value = fetchurl {
      inherit (wallpaper) name sha256;
      url = "https://i.imgur.com/${wallpaper.id}.${wallpaper.ext}";
    };
  })
  (lib.importJSON ./list.json))
