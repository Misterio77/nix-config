{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";
    nur.url = "github:nix-community/NUR";
    declarative-cachix.url = "github:jonascarpay/declarative-cachix";
    impermanence.url = "github:RiscadoA/impermanence";

    home-manager.url = "github:misterio77/home-manager/personal";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { ... } @ inputs:
    let lib = import ./lib { inherit inputs; };
    in {
      overlay = import ./overlays;
      nixosConfigurations = {
        atlas = lib.mkHost {
          host = "atlas";
          system = "x86_64-linux";
          users = [ "misterio" ];
        };
      };
    };
}

