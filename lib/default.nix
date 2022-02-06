{ inputs, overlays }:
{
  mkSystem =
    { hostname
    , system
    , users ? [ ]
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs system;
      };
      modules = [
        ./modules/nixos
        ./hosts/${hostname}
        {
          networking.hostName = hostname;
          # Apply overlay and allow unfree packages
          nixpkgs = {
            inherit overlays;
            config.allowUnfree = true;
          };
          # Add each input as a registry
          nix.registry = inputs.nixpkgs.lib.mapAttrs'
            (n: v:
              inputs.nixpkgs.lib.nameValuePair (n) ({ flake = v; }))
            inputs;
        }
        # System wide config for each user
      ] ++ inputs.nixpkgs.lib.forEach users
        (u: ./users/${u}/system);
    };

  mkHome =
    { username
    , system
    , hostname
    , persistence ? false
    , graphical ? false
    , keys ? false
    , colorscheme ? "nord"
    , wallpaper ? null
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit username system;
      extraSpecialArgs = {
        inherit system hostname persistence graphical keys colorscheme wallpaper inputs;
      };
      homeDirectory = "/home/${username}";
      configuration = ./users/${username}/home;
      extraModules = [
        ./modules/home-manager
        # Base configuration
        {
          nixpkgs = {
            inherit overlays;
            config.allowUnfree = true;
          };
          programs = {
            home-manager.enable = true;
            git.enable = true;
          };
          systemd.user.startServices = "sd-switch";
        }
      ];
    };
}
