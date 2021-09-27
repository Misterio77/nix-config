{ inputs }: {
  # Simplifies making a host
  # Takes the hostname, system type, and array of user names
  mkHost = { host, system, users ? [ ] }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit host;
        hardware = inputs.hardware.nixosModules;
        nixpkgs = inputs.nixpkgs;
        nur = inputs.nur;
      };
      modules = [
        # Import host config
        ../hosts/${host}
        # My custom NixOS modules
        ../modules/nixos
        # Package overlays
        ../overlays
        # Import impermanence and cachix
        inputs.impermanence.nixosModules.impermanence
        inputs.declarative-cachix.nixosModules.declarative-cachix
      ]
      # Plus system-level user config for each user
        ++ inputs.nixpkgs.lib.forEach users (user: ../users/${user})
        # And each user's home-manager config
        ++ [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit host; };
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [
                # My custom home-manager modules
                ../modules/home-manager
                # Import impermanence
                inputs.impermanence.nixosModules.home-manager.impermanence
              ];
              users = builtins.listToAttrs (inputs.nixpkgs.lib.forEach users (user: {
                name = user;
                value = ../users/${user}/home;
              }));
            };
          }
        ];
    };
}
