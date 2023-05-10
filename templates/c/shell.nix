{ callPackage, clang-tools }:

let
  mainPkg = callPackage ./default.nix { };
in
mainPkg.overrideAttrs (oa: {
  nativeBuildInputs = [
    clang-tools
  ] ++ (oa.nativeBuildInputs or [ ]);
})
