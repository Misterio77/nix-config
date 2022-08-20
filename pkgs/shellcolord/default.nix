{ lib, stdenv, fetchFromSourcehut }:

with lib;

stdenv.mkDerivation rec {
  name = "shellcolord";
  version = "0.1";
  src = fetchFromSourcehut {
    owner = "~misterio";
    repo = name;
    rev = "c761072952bba8bdc21b906fdc941b9ae5ac5432";
    sha256 = "sha256-SLMAZy9UxQOA+2YhnryJ5ZvMXOf/Bxv0E8gIbP32XfE=";
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
