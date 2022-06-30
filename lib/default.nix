{ inputs, ... }:
let
  inherit (builtins) mapAttrs attrValues;
  inherit (inputs) self home-manager nixpkgs deploy-rs;
  inherit (nixpkgs.lib) nixosSystem hasSuffix removeSuffix filterAttrs mapAttrs';
  inherit (home-manager.lib) homeManagerConfiguration;
  # Given hostname, get system kind
  getSystemKind = hostname: self.outputs.nixosConfigurations.${hostname}.pkgs.system;
  # Given hostname, get home configs
  getHomes = hostname:
    let suffix = "@${hostname}";
    in mapAttrs' (name: value: { name = removeSuffix suffix name; inherit value; })
      (filterAttrs (name: _: hasSuffix suffix name) self.outputs.homeConfigurations);

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
          homeConfigurations = getHomes hostname;
        };
        modules = attrValues (import ../modules/nixos) ++ [
          ../hosts/${hostname}
        ];
      };

    mkHome =
      { username
      , hostname ? null
      , system ? getSystemKind hostname
      , packages
      , persistence ? false
      , colorscheme ? null
      , wallpaper ? null
      , desktop ? null
      , features ? [ ]
      }:
      homeManagerConfiguration {
        pkgs = packages.${system};
        extraSpecialArgs = {
          inherit mylib inputs system hostname username persistence colorscheme wallpaper features desktop;
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
