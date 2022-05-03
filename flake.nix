{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    impermanence.url = "github:RiscadoA/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";

    paste-misterio-me.url = "github:misterio77/paste.misterio.me/1.3.0";
    paste-misterio-me.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      my-lib = import ./lib { inherit inputs; };
      inherit (builtins) attrValues;
      inherit (my-lib) mkSystem mkHome deployNixos importAttrset;
      inherit (inputs.nixpkgs.lib) genAttrs systems;
      forAllSystems = genAttrs systems.supported.hydra;
    in
    rec {
      overlays = {
        default = import ./overlay { inherit inputs; };
        nur = inputs.nur.overlay;
        paste-misterio-me = inputs.paste-misterio-me.overlay;
        deploy-rs = inputs.deploy-rs.overlay;
      };

      packages = forAllSystems (system:
        let
          pkgs = import inputs.nixpkgs { inherit system; overlays = attrValues overlays; };
        in
        builtins.removeAttrs pkgs [ "system" ]
      );

      devShells = forAllSystems (system: {
        default = import ./shell.nix { pkgs = packages.${system}; };
      });

      nixosModules = importAttrset ./modules/nixos;
      homeManagerModules = importAttrset ./modules/home-manager;

      templates = import ./templates;

      nixosConfigurations = {
        atlas = mkSystem {
          inherit overlays;
          hostname = "atlas";
          system = "x86_64-linux";
          users = [ "misterio" ];
        };
        pleione = mkSystem {
          inherit overlays;
          hostname = "pleione";
          system = "x86_64-linux";
          users = [ "misterio" ];
        };
        merope = mkSystem {
          inherit overlays;
          hostname = "merope";
          system = "aarch64-linux";
          users = [ "misterio" ];
        };
        maia = mkSystem {
          inherit overlays;
          hostname = "maia";
          system = "x86_64-linux";
          users = [ "layla" "misterio" ];
        };
      };

      homeConfigurations = {
        "misterio@atlas" = mkHome {
          inherit overlays;
          username = "misterio";
          system = "x86_64-linux";
          hostname = "atlas";

          graphical = true;
          trusted = true;
          colorscheme = "phd";
        };
        "misterio@pleione" = mkHome {
          inherit overlays;
          username = "misterio";
          system = "x86_64-linux";
          hostname = "pleione";

          graphical = true;
          trusted = true;
          colorscheme = "silk-dark";
        };
        "misterio@merope" = mkHome {
          inherit overlays;
          username = "misterio";
          system = "aarch64-linux";
          hostname = "merope";

          colorscheme = "nord";
        };
        "misterio@maia" = mkHome {
          inherit overlays;
          username = "misterio";
          system = "x86_64-linux";
          hostname = "maia";

          colorscheme = "ashes";
        };

        "layla@maia" = mkHome {
          inherit overlays;
          username = "layla";
          hostname = "maia";
          system = "x86_64-linux";

          graphical = true;
          colorscheme = "dracula";
        };
      };

      deploy = {
        user = "root";
        nodes = {
          merope = {
            hostname = "merope.local";
            profiles.system.path = deployNixos nixosConfigurations.merope;
          };
        };
      };
    };
}
