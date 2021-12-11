{ lib, stdenv, fetchFromSourcehut }:

with lib;

stdenv.mkDerivation rec {
  name = "shellcolord";
  version = "0.1";
  src = fetchFromSourcehut {
    owner = "~misterio";
    repo = name;
    rev = "250cb20b9d931092ddd9ccf1f66d52aaf72b71b7";
    sha256 = "sha256-eL+4ikdTiwoMB/gu1CTYTL+V2tnVDo03Mwh4a9nuT38=";
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
