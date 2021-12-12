{
  description = "Foo Bar C/C++ Project";

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
        packages.${name} = pkgs.stdenv.mkDerivation rec {
          inherit name;
          src = ./.;
          makeFlags = [ "PREFIX=$(out)" ];
        };
        defaultPackage = packages.${name};

        # nix run
        apps.${name} = {
          type = "app";
          program = "${packages.${name}}/bin/${name}";
        };
        defaultApp = apps.${name};

        # nix develop
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ clang clang-tools ];
          inputsFrom = builtins.attrValues self.packages.${system};
        };
      });
}

