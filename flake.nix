{
  description = "My NixOS configuration";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";
    hardware.url = "github:nixos/nixos-hardware";
    impermanence.url = "github:RiscadoA/impermanence";
    nur.url = "github:nix-community/NUR";
  };

  outputs = {... }@inputs:
  let
    # Make system configuration, given hostname and system type
    mkSystem = { hostname, system }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostname}
          ./modules/nixos
          ./overlays
        ];
      };
    # Make home configuration, given username, hostname, and system type
    mkHome = { username, hostname, system }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit username system;
        extraSpecialArgs = { inherit inputs hostname; };
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
    # Devshell for bootstrapping
    // inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
      home-manager = inputs.home-manager.defaultPackage.${system};
    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          git
          neovim
          nixUnstable
          home-manager
          nixfmt
        ];
      };
    });
}
