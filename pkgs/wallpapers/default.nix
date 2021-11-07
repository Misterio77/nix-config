{ lib, stdenv }:

stdenv.mkDerivation rec {
  name = "wallpapers";
  version = "595a4d0";
  src = fetchTarball {
    url = "https://github.com/Misterio77/wallpapers/releases/download/${version}/wallpapers.tar.gz";
    sha256 = "sha256:11sjcbgwsxwzwlidp30nfmiv6w5z6025d0c84lblm0pvda9zg98d";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm0644 -t $out/share/backgrounds *.{png,jpg}
  '';

  meta = {
    description = "My wallpaper collection";
    homepage = "https://github.com/Misterio77/wallpapers";
    platforms = lib.platforms.all;
  };
}
