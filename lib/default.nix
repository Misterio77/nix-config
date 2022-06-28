{ inputs, ... }:
let
  inherit (builtins) mapAttrs attrValues;
  inherit (inputs) self home-manager nixpkgs deploy-rs;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  getSystem = h: self.outputs.nixosConfigurations.${h}.pkgs.system;
  mylib = {
    importAttrset = path: mapAttrs (_: import) (import path);

    mkSystem =
      { hostname
      , system
      , packages
      , persistence ? false
      }:
      nixosSystem {
        inherit system;
        pkgs = packages.${system};
        specialArgs = {
          inherit mylib inputs system hostname persistence;
        };
        modules = attrValues (import ../modules/nixos) ++ [
          ../hosts/${hostname}
        ];
      };

    mkHome =
      { username
      , hostname ? null
      , system ? getSystem hostname
      , packages
      , persistence ? false
      , colorscheme ? "nord"
      , wallpaper ? null
      , desktop ? null
      , features ? [ ]
      }:
      homeManagerConfiguration {
        pkgs = packages.${system};
        extraSpecialArgs = {
          inherit mylib inputs system username persistence colorscheme wallpaper features desktop;
        };
        modules = attrValues (import ../modules/home-manager) ++ [
          ../home/${username}
        ];
      };

    mkDeploy = hostname: config: {
      inherit hostname;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.${config.pkgs.system}.activate.nixos config;
      };
    };

    # Helps checking for features
    has = element: builtins.any (x: x == element);
  };
in
mylib
