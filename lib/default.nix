{ inputs, ... }:
let
  inherit (builtins) mapAttrs attrValues listToAttrs;
  inherit (inputs.nixpkgs.lib) nixosSystem mapAttrs' nameValuePair forEach;
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
    nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs system hostname persistence users;
        # Expose home-configurations for each user on that system
        homeConfigs = listToAttrs (forEach users (username: {
          name = username;
          # Fallback to empty set if the configuration does not exist
          value = inputs.self.outputs.homeConfigurations."${username}@${hostname}".config or { };
        }));
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
          nix.registry = mapAttrs'
            (n: v:
              nameValuePair n { flake = v; })
            inputs;
        }
        # System wide config for each user
      ] ++ forEach users
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

  mkDeploy = config: {
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.${config.pkgs.system}.activate.nixos config;
    };
  };
}
