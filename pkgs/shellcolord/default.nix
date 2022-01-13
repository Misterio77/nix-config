{ lib, stdenv, fetchFromSourcehut }:

with lib;

stdenv.mkDerivation rec {
  name = "shellcolord";
  version = "0.1";
  src = fetchFromSourcehut {
    owner = "~misterio";
    repo = name;
    rev = "aded655522cd77ffccb1a226a2a739a8e0eadb23";
    sha256 = "sha256-0aBG0rzXj55IPrvYvBURxjZhSG+FFHv8Dz9uxg+TzPE=";
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
