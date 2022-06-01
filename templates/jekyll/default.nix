{ stdenv, ruby, bundlerEnv, lib }:
stdenv.mkDerivation rec {
  name = "foo-bar";
  src = ./.;

  JEKYLL_ENV = "production";

  buildInputs =
    [
      ruby
      (bundlerEnv {
        inherit ruby name;
        gemdir = ./.;
      })
    ];

  buildPhase = ''
    jekyll build
  '';
  installPhase = ''
    mkdir -p $out
    cp -Tr _site $out
  '';
}
