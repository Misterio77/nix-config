{ clangStdenv }:

clangStdenv.mkDerivation {
  pname = "foo-bar";
  version = "0.1.0";

  src = ./.;
  makeFlags = [ "PREFIX=$(out)" ];
}
