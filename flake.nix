{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, home-manager, nixpkgs, impermanence, hardware }: 
  let
    # For a list of users, get their configuration (./users/name),
    # plus their home-manager configuration (./users/name/home)
    users = users: nixpkgs.lib.flatten (nixpkgs.lib.forEach users (user: [
      (./users + "/${user}")
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${user} = (./users + "/${user}" + /home);
        };
      }
    ]));
  in {
    # Hosts
    nixosConfigurations = {
      thanatos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/thanatos ] ++ users [ "misterio" ];
      };
    };
  };
}

