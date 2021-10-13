{
  description = "Foo Bar Rust Project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        name = "foo-bar";
        pkgs = (import nixpkgs { inherit system; });
      in
      rec {
        # nix build
        packages.${name} = (import ./Cargo.nix { inherit pkgs; }).rootCrate.build;
        defaultPackage = packages.${name};

        # nix run
        apps.${name} = {
          type = "app";
          program = "${packages.${name}}/bin/${name}";
        };
        defaultApp = apps.${name};

        # nix develop
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ crate2nix rustc cargo rust-analyzer rustfmt clippy ];
        };
      });
}

