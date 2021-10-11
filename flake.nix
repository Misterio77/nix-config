{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hardware.url = "github:nixos/nixos-hardware";

    nur.url = "github:nix-community/NUR";

    declarative-cachix.url = "github:jonascarpay/declarative-cachix";
    impermanence.url = "github:RiscadoA/impermanence";
    nix-colors.url = "github:Misterio77/nix-colors";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = { nixpkgs, home-manager, hardware, nur,
  declarative-cachix, impermanence, nix-colors, flake-utils, ... }:
    let
      # Make system configuration, given hostname and system type
      mkSystem = { hostname, system }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit nixpkgs hardware nur declarative-cachix
              impermanence nix-colors;
          };
          modules = [ ./hosts/${hostname} ./overlays ];
        };
      # Make home configuration, given username, hostname, and system type
      mkHome = { username, hostname, system }:
        home-manager.lib.homeManagerConfiguration {
          inherit username system;
          extraSpecialArgs = {
            inherit hostname nur impermanence nix-colors;
          };
          configuration = ./users/${username};
          extraModules = [ ./modules/home-manager ./overlays ];
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
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        hm = home-manager.defaultPackage.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ git neovim nixUnstable hm nixfmt ];
        };
      });
}
