{
  description = "Foo Bar Python Project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";

    poetry2nix.url = "github:nix-community/poetry2nix";
    poetry2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, utils, poetry2nix }:
    {
      overlays = rec {
        default = f: p: {
          foo-bar = f.callPackage ./. { };
        };
      };
    } //
    (utils.lib.eachDefaultSystem (system:
      let
        inherit (builtins) attrValues;
        pkgs = import nixpkgs { inherit system; overlays = attrValues self.overlays; };
      in
      rec {
        packages = rec {
          inherit (pkgs) foo-bar;
          default = foo-bar;
        };

        devShells = rec {
          foo-bar = pkgs.mkShell {
            inputsFrom = [ packages.foo-bar ];
            buildInputs = with pkgs; [ poetry ];
          };
          default = foo-bar;
        };
      }));
}

