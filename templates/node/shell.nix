{ callPackage, writeShellScriptBin }:

let
  mainPkg = callPackage ./default.nix { };
  npxAlias = name: writeShellScriptBin name "npx ${name} \"$@\"";
in
mainPkg.overrideAttrs (oa: {
  nativeBuildInputs = [
    (npxAlias "tsc")
    (npxAlias "tsserver")
  ] ++ (oa.nativeBuildInputs or [ ]);

  shellHook = ''
    npm install
  '';
})
