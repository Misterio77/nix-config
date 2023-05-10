{ callPackage, haskell-language-server, cabal-install }:

let
  mainPkg = callPackage ./default.nix { };
in
mainPkg.overrideAttrs (oa: {
  nativeBuildInputs = [
    cabal-install
    haskell-language-server
  ] ++ (oa.nativeBuildInputs or [ ]);
})
