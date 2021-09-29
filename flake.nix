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
    let lib = import ./lib inputs;
    in {
      overlay = import ./overlays;
      nixosConfigurations = {
        # Main PC
        # Development, production, gaming
        # Wayland GUI
        # R5 3600X, RX 5700XT, 32GB RAM, 512GB SSD
        atlas = lib.mkHost {
          host = "atlas";
          system = "x86_64-linux";
          users = [ "misterio" ];
        };
        # Raspberry Pi 4B
        # Server usage
        # Headless
        # 8GB RAM, 64GB SD Card
        merope = lib.mkHost {
          host = "merope";
          system = "aarch64-linux";
          users = [ "misterio" ];
        };
      };
    };
}

