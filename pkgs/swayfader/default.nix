{ lib, stdenv, fetchFromGitHub, python3 }:

stdenv.mkDerivation {
  name = "swayfader";
  version = "master";

  src = fetchFromGitHub {
    owner = "Misterio77";
    repo = "swayfader";
    rev = "ee7151dc0ae43567b6b00212cabd5be88f010628";
    sha256 = "sha256-eg334cIPlUd+PAZG9F2DVllZVb/ldIhLp1e/f4i6Cz0=";
  };

  buildInputs = [ (python3.withPackages (ps: [ ps.i3ipc ])) ];

  installPhase = "install -Dm 0755 $src/swayfader.py $out/bin/swayfader";

  meta = with lib; {
    description = "Window fading script for swaywm";
    homepage = "https://github.com/jake-stewart/swayfader";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
