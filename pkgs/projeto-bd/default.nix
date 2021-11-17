{ lib, stdenv, fetchFromSourcehut, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "projeto-bd";
  version = "1.0.0-pre2";
  postInstall = ''
    install -d $out/etc
    cp -r templates assets $out/etc
  '';

  src = fetchFromSourcehut {
    owner = "~misterio";
    repo = "BSI-SCC0540-projeto";
    rev = version;
    sha256 = "sha256-JJOHAH7+wsBpN4H8PtZRQFaOi0IJmbKQRRg3GfImkoI=";
  };

  cargoHash = "sha256-ZRq/2rfz/Rutaoum1zXU+9cdO1AORgJPEjWYTB/GEeM=";

  meta = with lib; {
    description = "Projeto de BD 2021";
    homepage = "https://sr.ht/~misterio/BSI-SCC0540-projeto";
    license = licenses.mit;
  };
}
