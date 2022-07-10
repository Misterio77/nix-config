{ inputs, ... }:
let
  inherit (inputs) self home-manager nixpkgs deploy-rs;
  inherit (self) outputs;

  mylib = {
    has = element: builtins.any (x: x == element);

    importAttrset = path: builtins.mapAttrs (_: import) (import path);

    mkSystem =
      { hostname
      , system
      , packages
      , persistence ? false
      }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        pkgs = packages.${system};
        specialArgs = {
          inherit mylib inputs outputs hostname persistence;
        };
        modules = builtins.attrValues (import ../modules/nixos) ++ [
          ../hosts/${hostname}
        ];
      };

    mkHome =
      { username
      , hostname ? null
      , system ? outputs.nixosConfigurations.${hostname}.pkgs.system
      , packages
      , persistence ? false
      , colorscheme ? null
      , wallpaper ? null
      , desktop ? null
      , features ? [ ]
      }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = packages.${system};
        extraSpecialArgs = {
          inherit mylib inputs outputs hostname username persistence colorscheme wallpaper desktop features;
        };
        modules = builtins.attrValues (import ../modules/home-manager) ++ [
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
  };
in
mylib
