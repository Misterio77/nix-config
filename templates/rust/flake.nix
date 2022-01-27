{
  description = "Foo Bar Rust Project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    let
      name = "foo-bar";
      overlay = final: prev: {
        ${name} = final.callPackage ./default.nix { };
      };
      overlays = [ overlay ];
    in {
      inherit overlay overlays;
    } //
    (utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
      in
      rec {
        # nix build
        packages.${name} = pkgs.${name};
        defaultPackage = packages.${name};

        # nix run
        apps.${name} = utils.lib.mkApp { drv = packages.${name}; };
        defaultApp = apps.${name};

        # nix develop
        devShell = pkgs.mkShell {
          inputsFrom = [ defaultPackage ];
          buildInputs = with pkgs; [ rustc rust-analyzer rustfmt clippy ];
        };
      }));
}

