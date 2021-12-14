{ lib, stdenv, fetchFromSourcehut }:

with lib;

stdenv.mkDerivation rec {
  name = "shellcolord";
  version = "0.1";
  src = fetchFromSourcehut {
    owner = "~misterio";
    repo = name;
    rev = "7e0b2de84f0d4b6a1e1df0ed72da5a0ab571be75";
    sha256 = "sha256-KF2tpMZgboMAsOPcOwpHytcJFGd+LMwMJ23PkNvywKw=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "A daemon that themes your shell remotely";
    homepage = "https://git.sr.ht/~misterio/${name}";
    license = licenses.unlicense;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}
