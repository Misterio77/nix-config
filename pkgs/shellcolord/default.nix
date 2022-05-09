{ lib, stdenv, fetchFromSourcehut }:

with lib;

stdenv.mkDerivation rec {
  name = "shellcolord";
  version = "0.1";
  src = fetchFromSourcehut {
    owner = "~misterio";
    repo = name;
    rev = "769937036cf2778d28ac28db92157d31527e4b70";
    sha256 = "sha256-RFxaMR7m9YZNga3UkWU8ym+iQS4AP27+u4W2kcBkiM8=";
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
