{
  description = "Foo Bar Rust Project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nmattia/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, naersk }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        name = "foo-bar";
        pkgs = (import nixpkgs { inherit system; });
        naersk-lib = naersk.lib."${system}";
      in rec {
        # nix build
        packages.${name} = naersk-lib.buildPackage {
          pname = name;
          root = ./.;
        };
        defaultPackage = packages.${name};

        # nix run
        apps.${name} = flake-utils.lib.mkApp { drv = packages.${name}; };
        defaultApp = apps.${name};

        # nix develop
        devShell = pkgs.mkShell {
          inputsFrom =  [ defaultPackage ];
          buildInputs = with pkgs; [ rustc rust-analyzer rustfmt clippy ];
        };
      });
}

