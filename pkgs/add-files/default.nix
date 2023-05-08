{ lib, runCommand }:


drv: files:
let
  addScript = (lib.concatStringsSep "\n"
    (lib.mapAttrsToList (n: v: "cp ${v} $out/${n}") files)
  );
in
(runCommand drv.name { } ''
  cp ${drv} $out
'' + addScript) // {
  inherit (drv) pname version name meta passthru;
}
