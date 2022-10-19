{ stdenv, jekyll }:
stdenv.mkDerivation rec {
  name = "foo-bar";
  src = ./.;

  buildInputs = [ jekyll ];

  JEKYLL_ENV = "production";

  buildPhase = "jekyll build";

  installPhase = ''
    mkdir -p $out
    cp -Tr _site $out
  '';
}
