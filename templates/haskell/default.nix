{ haskellPackages }:

haskellPackages.callCabal2nix "foo-bar" ./. { }
