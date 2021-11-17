{ lib, stdenv, fetchFromSourcehut, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "projeto-bd";
  version = "1.0.0-pre1";
  postInstall = ''
    install -d $out/etc
    cp -r templates assets $out/etc
  '';

  src = fetchFromSourcehut {
    owner = "~misterio";
    repo = "BSI-SCC0540-projeto";
    rev = version;
    sha256 = "sha256-V9hfXC4f3BpYIEWhLVbSLj4Qo+XgMtmtHUWbVSA7/nE=";
  };

  cargoHash = "sha256-xNlspaKnQ2Uy9Xr/5cRZFaYbp7oj1dLTMzKgaeAYPq4=";

  meta = with lib; {
    description = "Projeto de BD 2021";
    homepage = "https://sr.ht/~misterio/BSI-SCC0540-projeto";
    license = licenses.mit;
  };
}
