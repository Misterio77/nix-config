{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware/master";
    #home-manager.url = "github:nix-community/home-manager";
    home-manager.url = "github:misterio77/home-manager/personal";
    #impermanence.url = "github:nix-community/impermanence";
    impermanence.url = "github:RiscadoA/impermanence";
  };

  outputs = { self, home-manager, nixpkgs, hardware, impermanence }:
    let
      # For a list of users, get their configuration (./users/name),
      # plus their home-manager configuration (./users/name/home)
      users = users:
        nixpkgs.lib.forEach users (user: (./users + "/${user}")) ++ [
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [ impermanence.nixosModules.impermanence-home ];
              users = builtins.listToAttrs (nixpkgs.lib.forEach users (user: {
                name = "${user}";
                value = (./users + "/${user}" + /home);
              }));
            };
          }
        ];
    in {
      # Hosts
      nixosConfigurations = {
        thanatos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/thanatos
            ./overlays
            hardware.nixosModules.common-cpu-amd
            hardware.nixosModules.common-gpu-amd
          ] ++ users [ "misterio" ];
        };
      };
    };
}

