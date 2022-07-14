{ inputs, ... }:
let
  inherit (inputs) self home-manager nixpkgs deploy-rs;
  inherit (self) outputs;

  mylib = rec {
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

    mkDeploys = hosts: users: builtins.listToAttrs (map (mkDeployHost users) hosts);

    mkDeployHost = users: hostname:
      let
        inherit (deploy-rs.lib.${config.pkgs.system}) activate;
        config = outputs.nixosConfigurations.${hostname};
      in
      {
        name = hostname;
        value =
          {
            inherit hostname;
            profiles = {
              system = {
                user = "root";
                path = activate.nixos config;
              };
            } // (builtins.listToAttrs (map (mkDeployHome hostname) users));
          };
      };

    mkDeployHome = hostname: username:
      let
        inherit (deploy-rs.lib.${config.pkgs.system}) activate;
        config = outputs.homeConfigurations."${username}@${hostname}";
      in
      {
        name = username;
        value = {
          user = username;
          path = activate.home-manager config;
        };
      };
  };
in
mylib
