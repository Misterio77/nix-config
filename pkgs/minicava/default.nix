{ lib, stdenv
, fetchFromGitHub, makeWrapper
, cava, gnused
}:

with lib;

stdenv.mkDerivation {
  pname = "minicava";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "Misterio77";
    repo = "minicava";
    rev = "cabb143e0f83706022f653c1566f3a8c3ce133bb";
    sha256 = "sha256-yJctepZrtxszfq+U5mrsTlzIW0R5ZAdjkCgQxukfUeo=";
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm 0755 minicava.sh $out/bin/minicava
    wrapProgram $out/bin/minicava --set PATH \
      "${makeBinPath [
        cava
        gnused
      ]}"
  '';

  meta = {
    description = "A miniature cava sound visualizer";
    homepage = "https://github.com/Misterio77/minicava";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
