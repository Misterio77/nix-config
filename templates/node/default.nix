{ buildNpmPackage }:

buildNpmPackage {
  pname = "foo-bar";
  version = "0.1.0";

  src = ./.;

  npmDepsHash = "sha256-ykdiIuGYEUrWitBnV9Z89FZXpnJ3ODms9xiWOEtW+1s=";
}
