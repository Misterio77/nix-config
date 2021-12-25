{
  description = "Foo Bar Rust Project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    naersk.url = "github:nmattia/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, naersk }:
    let
      name = "foo-bar";
      overlay = nixpkgs.lib.composeExtensions naersk.overlay (final: prev: {
        ${name} = final.naersk.buildPackage {
          pname = name;
          root = ./.;
        };
      });
      overlays = [ overlay ];
    in
    {
      inherit overlay overlays;
    } //
    (flake-utils.lib.eachDefaultSystem (system:
      let
        name = "foo-bar";
        pkgs = import nixpkgs { inherit system overlays; };
      in
      rec {
        # nix build
        packages.${name} = pkgs.${name};
        defaultPackage = packages.${name};

        # nix run
        apps.${name} = flake-utils.lib.mkApp { drv = packages.${name}; };
        defaultApp = apps.${name};

        # nix develop
        devShell = pkgs.mkShell {
          inputsFrom = [ defaultPackage ];
          buildInputs = with pkgs; [ rustc rust-analyzer rustfmt clippy ];
        };
      }));
}

