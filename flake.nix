{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    peerix = {
      url = "github:misterio77/peerix"; # TODO change to upstream after #13 is merged
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";
    impermanence.url = "github:misterio77/impermanence"; # TODO change to upstream after #99 is merged
    nix-colors.url = "github:misterio77/nix-colors";

    # Nixified third-party software
    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # My nixified software
    paste-misterio-me = {
      url = "github:misterio77/paste.misterio.me/1.3.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    projeto-lab-bd = {
      url = "github:misterio77/SCC0541-Lab-BD-Projeto";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      lib = import ./lib { inherit inputs; };
      inherit (lib) mkSystem mkHome mkDeploys importAttrset forAllSystems;
    in
    rec {
      inherit lib;

      overlays = {
        default = import ./overlay { inherit inputs; };
        nur = inputs.nur.overlay;
        deploy-rs = inputs.deploy-rs.overlay;
        peerix = inputs.peerix.overlay;
        sops-nix = inputs.sops-nix.overlay;
        hyprland = inputs.hyprland.overlays.default;
        paste-misterio-me = inputs.paste-misterio-me.overlay;
        projeto-lab-bd = inputs.projeto-lab-bd.overlays.default;
      };

      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;
          config.allowUnfree = true;
        }
      );

      apps = forAllSystems (system: rec {
        deploy = {
          type = "app";
          program = "${legacyPackages.${system}.deploy-rs.deploy-rs}/bin/deploy";
        };
        default = deploy;
      });

      devShells = forAllSystems (system: {
        default = legacyPackages.${system}.callPackage ./shell.nix { };
      });

      nixosModules = importAttrset ./modules/nixos;
      homeManagerModules = importAttrset ./modules/home-manager;

      templates = import ./templates;

      nixosConfigurations = {
        atlas = mkSystem {
          hostname = "atlas";
          system = "x86_64-linux";
          persistence = true;
        };
        pleione = mkSystem {
          hostname = "pleione";
          system = "x86_64-linux";
          persistence = true;
        };
        merope = mkSystem {
          hostname = "merope";
          system = "aarch64-linux";
          persistence = true;
        };
      };

      homeConfigurations = {
        # Personal computers
        "misterio@atlas" = mkHome {
          username = "misterio";
          hostname = "atlas";
          persistence = true;

          features = [
            "trusted"
            "rgb"
            "games"
          ];
          desktop = "hyprland";
          colorscheme = "catppuccin";
          wallpaper = "cartoon-mountain";
        };
        "misterio@pleione" = mkHome {
          username = "misterio";
          hostname = "pleione";
          persistence = true;

          features = [
            "trusted"
            "laptop"
            "games"
          ];
          desktop = "hyprland";
          colorscheme = "paraiso";
          wallpaper = "plains-gold-field";
        };
        "misterio@merope" = mkHome {
          username = "misterio";
          hostname = "merope";
          persistence = true;

          colorscheme = "nord";
        };

        # Generic configs
        "misterio@generic" = mkHome {
          username = "misterio";
          system = "x86_64-linux";

          colorscheme = "dracula";
        };
        "misterio@generic-gnome" = mkHome {
          username = "misterio";
          system = "x86_64-linux";

          desktop = "gnome";
          colorscheme = "dracula";
        };

        # GELOS lab computers
        "misterio@emperor" = homeConfigurations."misterio@generic";
        "misterio@galapagos" = homeConfigurations."misterio@generic";
        "misterio@macaroni" = homeConfigurations."misterio@generic-gnome";
        "misterio@rockhopper" = homeConfigurations."misterio@generic-gnome";
      };

      deploy.nodes = mkDeploys nixosConfigurations homeConfigurations;

      deployChecks = { };
    };
}
