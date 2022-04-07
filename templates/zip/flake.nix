{
  description = "Foo Bar Simple Zip Package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      name = "foo-bar";
      zipName = pkgs.lib.concatStringsSep "_" [ "10856803" ];
      overlay = _final: _prev: {
        ${name} = pkgs.stdenv.mkDerivation {
          inherit name;
          src = ./.;
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
      };
      overlays = [ overlay ];
    in
    {
      inherit overlay overlays;
    } //
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
      in
      rec {
        # nix build
        packages.${name} = pkgs.${name};
        defaultPackage = packages.${name};

        # nix develop
        devShell = pkgs.mkShell {
          inputsFrom = [ defaultPackage ];
          buildInputs = with pkgs; [ unzip ];
        };
      }));
}
