{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    hardware = { url = "github:nixos/nixos-hardware/master"; };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = { url = "github:nix-community/impermanence"; };
  };

  outputs = { self, home-manager, nixpkgs, impermanence, hardware }: {

    nixosConfigurations.thanatos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/thanatos
        hardware.nixosModules.common-gpu-amd
        hardware.nixosModules.common-cpu-amd
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.misterio = import ./users/misterio/home;
          };
        }
      ];
    };
  };
}
