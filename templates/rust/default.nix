{ lib, rustPlatform }:

let manifest = (lib.importTOML ./Cargo.toml).package;
in
rustPlatform.buildRustPackage rec {
  pname = manifest.name;
  version = manifest.version;

  src = lib.cleanSource ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta = with lib; {
    description = manifest.description;
    homepage = manifest.homepage;
    platforms = platforms.all;
  };
}
