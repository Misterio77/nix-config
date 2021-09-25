{ inputs }: {
  # Simplifies making a host
  # Takes the hostname, system type, and array of user names
  mkHost = { host, system, users ? [ ] }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        declarative-cachix = inputs.declarative-cachix;
        hardware = inputs.hardware;
        impermanence = inputs.impermanence;
        nixpkgs = inputs.nixpkgs;
        nur = inputs.nur;
      };
      # Import host config
      modules = [ ../hosts/${host} ]
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
              sharedModules =
                [ inputs.impermanence.nixosModules.home-manager.impermanence ];
              users = builtins.listToAttrs (inputs.nixpkgs.lib.forEach users (user: {
                name = user;
                value = ../users/${user}/home;
              }));
            };
          }
        ];
    };
}
