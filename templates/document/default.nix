{ stdenv, pandoc, texlive }: stdenv.mkDerivation {
  pname = "foo-bar";
  version = "0.1.0";
  src = ./.;
  buildInputs = [ pandoc texlive.combined.scheme-small ];
  buildPhase = ''
    shopt -s globstar
    pandoc src/**/*.md -o document.pdf
  '';
  installPhase = ''
    mkdir -p $out
    install -Dm644 *.pdf $out
  '';
}
