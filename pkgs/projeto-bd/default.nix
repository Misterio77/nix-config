{ lib, stdenv, fetchFromSourcehut, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "projeto-bd";
  version = "0.1.0";
  postInstall = "cp -r templates assets $out/bin";

  src = fetchFromSourcehut {
    owner = "~misterio";
    repo = "BSI-SCC0540-projeto";
    rev = version;
    sha256 = "sha256-3+0oyDCW6MWBH2QPZXUckkGYn/AUJdJcxUTq1zPjaEQ=";
  };

  cargoHash = "sha256-3R9nyu4jshPNmAmf9I7C0cn3krRlDaS4+J8fno4hkn8=";

  meta = with lib; {
    description = "Projeto de BD 2021";
    homepage = "https://sr.ht/~misterio/BSI-SCC0540-projeto";
    license = licenses.mit;
  };
}
