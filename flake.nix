{
  description = "My NixOS configuration";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    # Nix tooling
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Community flakes
    nur.url = "github:nix-community/NUR";
    impermanence.url = "github:RiscadoA/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";

    # Nixified projects
    paste-misterio-me.url = "github:misterio77/paste.misterio.me/1.3.0";
    paste-misterio-me.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      my-lib = import ./lib { inherit inputs; };
      inherit (builtins) attrValues;
      inherit (my-lib) mkSystem mkHome importAttrset;
      inherit (inputs.nixpkgs.lib) genAttrs systems;
      forAllSystems = genAttrs systems.supported.hydra;
    in
    rec {
      overlays = {
        default = import ./overlay { inherit inputs; };
        nur = inputs.nur.overlay;
        paste-misterio-me = inputs.paste-misterio-me.overlay;
      };

      packages = forAllSystems (system:
        import inputs.nixpkgs { inherit system; overlays = attrValues overlays; }
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
          users = [ "misterio" ];
          persistence = true;
        };
        pleione = mkSystem {
          inherit overlays;
          hostname = "pleione";
          users = [ "misterio" ];
          persistence = true;
        };
        merope = mkSystem {
          inherit overlays;
          system = "aarch64-linux";
          hostname = "merope";
          users = [ "misterio" ];
          persistence = true;
        };
        maia = mkSystem {
          inherit overlays;
          hostname = "maia";
          users = [ "layla" "misterio" ];
          persistence = true;
        };
      };

      homeConfigurations = {
        # Personal computers
        "misterio@atlas" = mkHome {
          inherit overlays;
          username = "misterio";

          desktop = "sway";
          persistence = true;
          trusted = true;
          rgb = true;
          games = true;
          colorscheme = "dracula";
        };
        "misterio@pleione" = mkHome {
          inherit overlays;
          username = "misterio";

          desktop = "sway";
          persistence = true;
          trusted = true;
          laptop = true;
          games = true;
          colorscheme = "paraiso";
        };
        "misterio@merope" = mkHome {
          inherit overlays;
          username = "misterio";
          system = "aarch64-linux";

          persistence = true;
          colorscheme = "nord";
        };
        "misterio@maia" = mkHome {
          inherit overlays;
          username = "misterio";

          desktop = "gnome";
          persistence = true;
          colorscheme = "ashes";
        };

        # Generic lab configurations
        "misterio@lab" = mkHome {
          inherit overlays;
          username = "misterio";

          colorscheme = "dracula";
        };
        "misterio@lab-graphical" = mkHome {
          inherit overlays;
          username = "misterio";

          desktop = "gnome";
          colorscheme = "phd";
        };
        # GELOS lab computers
        "misterio@emperor" = homeConfigurations."misterio@lab";
        "misterio@galapagos" = homeConfigurations."misterio@lab";
        "misterio@macaroni" = homeConfigurations."misterio@lab-graphical";
        "misterio@rockhopper" = homeConfigurations."misterio@lab-graphical";

        "layla@maia" = mkHome {
          inherit overlays;
          username = "layla";

          desktop = "gnome";
          colorscheme = "dracula";
        };
      };
    };
}
