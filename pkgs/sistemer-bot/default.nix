{ lib, stdenv, fetchFromSourcehut, rustPlatform, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "sistemer-bot";
  version = "1.1.2";

  src = fetchFromSourcehut {
    owner = "~misterio";
    repo = pname;
    rev = version;
    sha256 = "sha256-O4y9sPGsH9LXVlId3uskDyQk/pwp5lov2pe6tRX2WNM=";
  };

  cargoHash = "sha256-dzQ97M6QCQTBqgBahHhSpvvWm6+WTs5ONZWatAfsIZQ=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = "Bot do telegram para o bsi 020";
    homepage = "https://sr.ht/~misterio/${pname}";
    license = licenses.mit;
  };
}
