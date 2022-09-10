{ lib, stdenv, fetchurl, wallpaper }:
stdenv.mkDerivation {
  name = "wallpaper-${wallpaper.name}.${wallpaper.ext}";
  src = fetchurl {
    inherit (wallpaper) sha256;
    url = "https://i.imgur.com/${wallpaper.id}.${wallpaper.ext}";
  };
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm0644 $src $out
  '';

  meta = {
    description = "Wallpaper: ${wallpaper.name}";
    platforms = lib.platforms.all;
  };
}
