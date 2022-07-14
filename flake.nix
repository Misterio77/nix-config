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
      my-lib = import ./lib { inherit inputs; };
      inherit (builtins) attrValues mapAttrs;
      inherit (my-lib) mkSystem mkHome mkDeploy importAttrset;
      inherit (inputs.nixpkgs.lib) genAttrs systems;
      forAllSystems = genAttrs systems.flakeExposed;
    in
    rec {
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

      packages = forAllSystems (system:
        import inputs.nixpkgs {
          inherit system;
          overlays = attrValues overlays;
          config.allowUnfree = true;
        }
      );

      devShells = forAllSystems (system: {
        default = import ./shell.nix { pkgs = packages.${system}; };
      });

      nixosModules = importAttrset ./modules/nixos;
      homeManagerModules = importAttrset ./modules/home-manager;

      templates = import ./templates;

      nixosConfigurations = {
        atlas = mkSystem {
          inherit packages;
          hostname = "atlas";
          system = "x86_64-linux";
          persistence = true;
        };
        pleione = mkSystem {
          inherit packages;
          hostname = "pleione";
          system = "x86_64-linux";
          persistence = true;
        };
        merope = mkSystem {
          inherit packages;
          hostname = "merope";
          system = "aarch64-linux";
          persistence = true;
        };
      };

      deploy.nodes = {
        inherit (mapAttrs mkDeploy nixosConfigurations) merope pleione atlas;
      };

      homeConfigurations = {
        # Personal computers
        "misterio@atlas" = mkHome {
          inherit packages;
          username = "misterio";
          hostname = "atlas";
          colorscheme = "catppuccin";
          wallpaper = "cartoon-mountain";
          persistence = true;
          desktop = "hyprland";
          features = [
            "trusted"
            "rgb"
            "games"
          ];
        };
        "misterio@pleione" = mkHome {
          inherit packages;
          username = "misterio";
          hostname = "pleione";
          colorscheme = "paraiso";
          wallpaper = "plains-gold-field";
          persistence = true;
          desktop = "hyprland";
          features = [
            "trusted"
            "laptop"
            "games"
          ];
        };
        "misterio@merope" = mkHome {
          inherit packages;
          username = "misterio";
          hostname = "merope";
          colorscheme = "nord";
          persistence = true;
        };

        # Generic configs
        "misterio@generic" = mkHome {
          inherit packages;
          username = "misterio";
          system = "x86_64-linux";
          colorscheme = "dracula";
        };
        "misterio@generic-gnome" = mkHome {
          inherit packages;
          username = "misterio";
          system = "x86_64-linux";
          colorscheme = "dracula";
          desktop = "gnome";
        };

        # GELOS lab computers
        "misterio@emperor" = homeConfigurations."misterio@generic";
        "misterio@galapagos" = homeConfigurations."misterio@generic";
        "misterio@macaroni" = homeConfigurations."misterio@generic-gnome";
        "misterio@rockhopper" = homeConfigurations."misterio@generic-gnome";
      };
    };
}
