{ stdenv, zip }: stdenv.mkDerivation rec {
  pname = "foo-bar";
  version = "0.1.0";
  src = ./.;
  buildInputs = [ zip ];
  buildPhase = ''
    # Do stuff
    zip -j ${pname}.zip src/*
  '';
  installPhase = ''
    mkdir -p $out
    install -Dm644 ${pname}.zip $out
  '';
}
