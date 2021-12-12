{
  description = "Foo Bar Simple Zip Package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pname = "assignment1";
        group = [ "10856803" ];
      in rec {
        packages.${pname} = let zipName = pkgs.lib.concatStringsSep "_" group;
        in pkgs.stdenv.mkDerivation {
          inherit pname;
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
        defaultPackage = packages.${pname};

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ unzip ];
          inputsFrom = builtins.attrValues self.packages.${system};
        };
      });
}
