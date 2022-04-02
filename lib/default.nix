{ inputs, overlays }:
{
  importAttrset = path: builtins.mapAttrs (_: v: import v) (import path);

  mkSystem =
    { hostname
    , system
    , users ? [ ]
    , persistence ? true
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs system hostname persistence;
      };
      modules = builtins.attrValues (import ../modules/nixos) ++ [
        ../hosts/${hostname}
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
        (u: ../users/${u}/system);
    };

  mkDroidSystem =
    { hostname
    , system
    }:
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      inherit system;
      extraSpecialArgs = {
        inherit inputs system hostname;
      };
      config = ../hosts/${hostname};
      extraModules = builtins.attrValues (import ../modules/nixondroid) ++ [
        {
          # Add each input as a registry
          nix.registry = inputs.nixpkgs.lib.mapAttrs'
            (n: v:
              inputs.nixpkgs.lib.nameValuePair (n) ({ flake = v; }))
            inputs;
        }
      ];
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = overlays ++ [ inputs.nix-on-droid.overlay ];
      };
    };

  mkHome =
    { username
    , system
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
      extraModules = builtins.attrValues (import ../modules/home-manager) ++ [
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
