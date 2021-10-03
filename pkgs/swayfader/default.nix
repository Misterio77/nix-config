{ lib, stdenv, fetchFromGitHub, python3 }:

stdenv.mkDerivation {
  name = "swayfader";
  version = "master";

  src = fetchFromGitHub {
    owner = "Misterio77";
    repo = "swayfader";
    rev = "2be57f2e0685e52d1141c57fb62efebed6e276b3";
    sha256 = "sha256-foMu5Qxx4PD5YI67TuEe+sydP+pERUjB3MyoGOhHrjw=";
  };

  buildInputs = [ (python3.withPackages (ps: [ ps.i3ipc ])) ];

  installPhase = "install -Dm 0755 $src/swayfader.py $out/bin/swayfader";

  meta = with lib; {
    description = "Window fading script for swaywm";
    homepage = "https://github.com/jake-stewart/swayfader";
    maintainers = with maintainers; [ misterio77 ];
    license = licenses.mit;
    platforms = platforms.all;
  };
}
