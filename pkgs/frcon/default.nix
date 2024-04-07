{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "frcon";
  version = "unstable-2024-03-07";
  src = fetchFromGitHub {
    owner = "emmalexandria";
    repo = "frcon";
    rev = "a602e2071d3b85b6263643066f6549e929d32b09";
    hash = "sha256-m0/lh0NFtUCdB/j5iBrar14cLrhe2AU13mAZyZ4A8VE=";
  };

  cargoHash = "sha256-55VOnmQN0+kN+c82Z1HZ5folKHzs/Kq8IPUEj0BKBW0=";

  meta = {
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
