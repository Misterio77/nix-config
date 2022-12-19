builtins.listToAttrs (map
  (wallpaper: {
    inherit (wallpaper) name;
    value = builtins.fetchurl {
      inherit (wallpaper) sha256;
      url = "https://i.imgur.com/${wallpaper.id}.${wallpaper.ext}";
    };
  })
  (builtins.fromJSON (builtins.readFile ./list.json)))
