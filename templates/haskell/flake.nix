{
  description = "Foo Bar Haskell Project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        name = "foo-bar";
        pkgs = (import nixpkgs { inherit system; });
      in rec {
        # nix build
        packages.${name} = pkgs.haskellPackages.callCabal2nix name ./. { };
        defaultPackage = packages.${name};

        # nix run
        apps.${name} = flake-utils.lib.mkApp { drv = packages.${name}; };
        defaultApp = apps.${name};

        # nix develop
        devShell = pkgs.mkShell {
          inputsFrom =  [ defaultPackage ];
          buildInputs = with pkgs; [ haskell-language-server cabal-install ghc ];
        };
      });
}

