{
  description = "Foo Bar Python Project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    compat.url = "github:edolstra/flake-compat";
    compat.flake = false;

    poetry2nix.url = "github:nix-community/poetry2nix";
    poetry2nix.inputs.nixpkgs.follows = "nixpkgs";
    poetry2nix.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, poetry2nix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        name = "foo-bar";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ poetry2nix.overlay ];
        };
      in rec {
        # nix build
        packages.${name} = pkgs.poetry2nix.mkPoetryApplication {
          projectDir = ./.;
          overrides = [ pkgs.poetry2nix.defaultPoetryOverrides ];
        };
        defaultPackage = self.packages.${system}.${name};

        # nix run
        apps.${name} = {
          type = "app";
          program = "${packages.${name}}/bin/${name}";
        };
        defaultApp = apps.${name};

        # nix develop
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ poetry ];
          inputsFrom = builtins.attrValues self.packages.${system};
        };
      });
}
