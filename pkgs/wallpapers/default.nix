{ lib, fetchurl }:
lib.listToAttrs (
  map (wallpaper: {
    inherit (wallpaper) name;
    value = fetchurl {
      inherit (wallpaper) sha256;
      name = "${wallpaper.name}.${wallpaper.ext}";
      url = "https://i.imgur.com/${wallpaper.id}.${wallpaper.ext}";
    };
  }) (lib.importJSON ./list.json)
)
