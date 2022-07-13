{ stdenv, ruby, bundlerEnv }:
stdenv.mkDerivation rec {
  name = "foo-bar";
  src = ./.;

  buildInputs = [
    ruby
    (bundlerEnv {
      inherit ruby name;
      gemdir = ./.;
    })
  ];

  JEKYLL_ENV = "production";

  buildPhase = ''
    jekyll build
  '';

  installPhase = ''
    mkdir -p $out
    cp -Tr _site $out
  '';
}
