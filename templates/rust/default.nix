{ lib, system, naersk }:

let
  manifest = (lib.importTOML ./Cargo.toml).package;
in
naersk.lib."${system}".buildPackage {
  inherit (manifest) version;
  pname = manifest.name;
  root = lib.cleanSource ./.;
}
