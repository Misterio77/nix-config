{
  description = "My NixOS configuration";

  inputs = {
    hardware.url = "github:nixos/nixos-hardware";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    impermanence.url = "github:RiscadoA/impermanence";
    home-manager = {
      url = "github:misterio77/home-manager/personal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, hardware, impermanence, nur }: {
    overlay = import ./overlays;
    nixosConfigurations = let
      # For a list of users, get their configuration (./users/name),
      # plus their home-manager configuration (./users/name/home)
      users = users:
        nixpkgs.lib.forEach users (user: (./users + "/${user}")) ++ [
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules =
                [ impermanence.nixosModules.home-manager.impermanence ];
              users = builtins.listToAttrs (nixpkgs.lib.forEach users (user: {
                name = "${user}";
                value = (./users + "/${user}" + /home);
              }));
            };
          }
        ];
    in {
      # Hosts
      thanatos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit hardware nixpkgs impermanence nur; };
        modules = [ ./hosts/thanatos ] ++ users [ "misterio" ];
      };
    };
  };
}

