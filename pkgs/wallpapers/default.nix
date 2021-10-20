{ lib, stdenv, fetchgit }:
with lib;

stdenv.mkDerivation rec {
  name = "wallpapers";
  version = "4e9f4e4";
  src = fetchTarball {
    url = "https://github.com/Misterio77/wallpapers/releases/download/${version}/wallpapers.tar.gz";
    sha256 = "sha256:1h67sd2hbf3l6dd0nyp90wi5j57vbd7fb8kgsadk7zscfpzx8dr8";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm0644 -t $out/share/backgrounds *.{png,jpg}
  '';

  meta = {
    description = "My wallpaper collection";
    homepage = "https://github.com/Misterio77/wallpapers";
    platforms = platforms.all;
  };
}
