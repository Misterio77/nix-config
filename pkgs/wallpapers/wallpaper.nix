{ lib, stdenv, fetchurl, wallpaper }:
stdenv.mkDerivation rec {
  name = "wallpaper-${wallpaper.name}";
  src = fetchurl {
    url = "https://i.imgur.com/${wallpaper.id}.${wallpaper.ext}";
    sha256 = wallpaper.sha256;
  };
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm0644 $src $out/share/backgrounds/${wallpaper.name}
  '';

  meta = {
    description = "Wallpaper: ${wallpaper.name}";
    platforms = lib.platforms.all;
  };
}
