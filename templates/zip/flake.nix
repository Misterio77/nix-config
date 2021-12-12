{
  description = "Foo Bar Simple Zip Package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        name = "assignment1";
        pkgs = import nixpkgs { inherit system; };
        group = [ "10856803" ];
        zipName = pkgs.lib.concatStringsSep "_" group;
      in rec {
        # nix build
        packages.${name} = pkgs.stdenv.mkDerivation {
            inherit name;
            version = "1.0";
            src = ./.;
            dontConfigure = true;
            buildInputs = with pkgs; [ zip ];
            buildPhase = ''
              # Do stuff
              zip -j ${zipName}.zip src/*
            '';
            installPhase = ''
              mkdir -p $out
              install -Dm644 ${zipName}.zip $out
            '';
          };
        defaultPackage = packages.${name};

        # nix develop
        devShell = pkgs.mkShell {
          inputsFrom = [ defaultPackage ];
          buildInputs = with pkgs; [ unzip ];
        };
      });
}
