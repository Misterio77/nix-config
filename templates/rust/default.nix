{ lib, rustPlatform }:

let manifest = (lib.importTOML ./Cargo.toml).package;
in
rustPlatform.buildRustPackage rec {
  pname = manifest.name;
  inherit (manifest) version;

  src = lib.cleanSource ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta = with lib; {
    inherit (manifest) description homepage;
    platforms = platforms.all;
  };
}
