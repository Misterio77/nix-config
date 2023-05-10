{ rustPlatform }:

rustPlatform.buildRustPackage {
  pname = "foo-bar";
  version = "0.1.0";

  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
}
