{
  description = "Foo Bar C/C++ Project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
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
            nativeBuildInputs = with pkgs; [ clang-tools ];
          };
          default = foo-bar;
        };
      }));
}

