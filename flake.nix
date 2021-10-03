{
  description = "My NixOS configuration";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    misterio-nur.url = "github:misterio77/nur-packages";

    declarative-cachix.url = "github:jonascarpay/declarative-cachix";
    hardware.url = "github:nixos/nixos-hardware";
    impermanence.url = "github:RiscadoA/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { nixpkgs, home-manager, nix-colors, hardware, impermanence, nur
    , flake-utils, misterio-nur, declarative-cachix, ... }:
    let
      # Make system configuration, given hostname and system type
      mkSystem = { hostname, system }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit nixpkgs nur misterio-nur declarative-cachix hardware
              impermanence nix-colors;
          };
          modules = [
            ./hosts/${hostname}
            ./overlays
          ];
        };
      # Make home configuration, given username, hostname, and system type
      mkHome = { username, hostname, system }:
        home-manager.lib.homeManagerConfiguration {
          inherit username system;
          extraSpecialArgs = {
            inherit hostname nur misterio-nur impermanence nix-colors;
          };
          configuration = ./users/${username};
          extraModules = [
            ./modules/home-manager
            ./overlays
          ];
          homeDirectory = "/home/${username}";
        };
    in {
      overlay = import ./overlays;
      nixosConfigurations = {
        # Main PC
        atlas = mkSystem {
          hostname = "atlas";
          system = "x86_64-linux";
        };
        # Raspberry Pi 4B
        merope = mkSystem {
          hostname = "merope";
          system = "aarch64-linux";
        };
      };
      homeConfigurations = {
        "misterio@atlas" = mkHome {
          username = "misterio";
          hostname = "atlas";
          system = "x86_64-linux";
        };
        "misterio@merope" = mkHome {
          username = "misterio";
          hostname = "merope";
          system = "aarch64-linux";
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        hm = home-manager.defaultPackage.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            hm
            nixfmt
          ];
        };
      });
}
