{ inputs, ... }:
let
  inherit (builtins) mapAttrs attrValues;
in
{
  importAttrset = path: mapAttrs (_: import) (import path);

  mkSystem =
    { hostname
    , system
    , overlays ? { }
    , users ? [ ]
    , persistence ? true
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs system hostname persistence;
      };
      modules = attrValues (import ../modules/nixos) ++ [
        ../hosts/${hostname}
        {
          networking.hostName = hostname;
          # Apply overlay and allow unfree packages
          nixpkgs = {
            overlays = attrValues overlays;
            config.allowUnfree = true;
          };
          # Add each input as a registry
          nix.registry = inputs.nixpkgs.lib.mapAttrs'
            (n: v:
              inputs.nixpkgs.lib.nameValuePair n { flake = v; })
            inputs;
        }
        # System wide config for each user
      ] ++ inputs.nixpkgs.lib.forEach users
        (u: ../users/${u}/system);
    };

  mkHome =
    { username
    , system
    , overlays ? { }
    , hostname
    , persistence ? true
    , graphical ? false
    , trusted ? false
    , colorscheme ? "nord"
    , wallpaper ? null
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit username system;
      extraSpecialArgs = {
        inherit system hostname persistence graphical trusted colorscheme wallpaper inputs;
      };
      homeDirectory = "/home/${username}";
      configuration = ../users/${username}/home;
      extraModules = attrValues (import ../modules/home-manager) ++ [
        # Base configuration
        {
          nixpkgs = {
            overlays = attrValues overlays;
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

  deployNixos = configuration:
    inputs.deploy-rs.lib.${configuration.config.nixpkgs.system}.activate.nixos
      configuration;
}
