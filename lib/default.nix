{ inputs, ... }:
let
  inherit (builtins) mapAttrs attrValues;
in
{
  importAttrset = path: mapAttrs (_: import) (import path);

  mkSystem =
    { hostname
    , system ? "x86_64-linux"
    , overlays ? { }
    , users ? [ ]
    , persistence ? false
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
    , system ? "x86_64-linux"
    , overlays ? { }
    , persistence ? false
    , desktop ? null
    , trusted ? false
    , laptop ? false
    , rgb ? false
    , games ? false
    , colorscheme ? "nord"
    , wallpaper ? null
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit username system;
      extraSpecialArgs = {
        inherit system persistence desktop trusted colorscheme wallpaper inputs rgb laptop games;
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
