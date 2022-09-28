{
  description = "My NixOS configuration";

  inputs = {
    # Nix ecossystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";
    nur.url = "github:nix-community/NUR";
    impermanence.url = "github:nix-community/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";

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
      url = "github:cid-chan/peerix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nixified software I use
    hyprland = {
      url = "github:hyprwm/hyprland/v0.13.1beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprwm-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal projects I deploy on my machines using nix
    website = {
      url = "github:misterio77/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paste-misterio-me = {
      url = "github:misterio77/paste.misterio.me/1.3.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      lib = import ./lib { inherit inputs; };
      inherit (lib) mkSystem mkHome mkDeploys forAllSystems;
    in
    rec {
      inherit lib;

      overlays = {
        default = import ./overlay { inherit inputs; };
        nur = inputs.nur.overlay;
        peerix = inputs.peerix.overlay;
        sops-nix = inputs.sops-nix.overlay;
        hyprland = inputs.hyprland.overlays.default;
        hyprwm-contrib = inputs.hyprwm-contrib.overlays.default;
        paste-misterio-me = inputs.paste-misterio-me.overlay;
        neovim-nightly-overlay = inputs.neovim-nightly-overlay.overlay;
        website = inputs.website.overlays.default;
      };

      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      templates = import ./templates;

      devShells = forAllSystems (system: {
        default = legacyPackages.${system}.callPackage ./shell.nix { };
      });

      apps = forAllSystems (system: rec {
        deploy = {
          type = "app";
          program = "${legacyPackages.${system}.deploy-rs}/bin/deploy";
        };
        default = deploy;
      });

      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;
          config.allowUnfree = true;
        }
      );

      nixosConfigurations = {
        # Desktop
        atlas = mkSystem {
          hostname = "atlas";
          pkgs = legacyPackages."x86_64-linux";
          persistence = true;
        };
        # Laptop
        pleione = mkSystem {
          hostname = "pleione";
          pkgs = legacyPackages."x86_64-linux";
          persistence = true;
        };
        # Secondary Desktop
        maia = mkSystem {
          hostname = "maia";
          pkgs = legacyPackages."x86_64-linux";
          persistence = true;
        };
        # Raspi 4
        merope = mkSystem {
          hostname = "merope";
          pkgs = legacyPackages."aarch64-linux";
          persistence = true;
        };
        # VPS
        electra = mkSystem {
          hostname = "electra";
          pkgs = legacyPackages."x86_64-linux";
          persistence = true;
        };
      };

      homeConfigurations = {
        # Desktop
        "misterio@atlas" = mkHome {
          username = "misterio";
          hostname = "atlas";
          persistence = true;

          features = [
            "desktop/hyprland"
            "trusted"
            "rgb"
            "games"
          ];
          wallpaper = "planet-red-desert";
          colorscheme = "purpledream";
        };
        # Laptop
        "misterio@pleione" = mkHome {
          username = "misterio";
          hostname = "pleione";
          persistence = true;

          features = [
            "desktop/hyprland"
            "trusted"
            "laptop"
            "games"
          ];
          colorscheme = "spaceduck";
        };
        # Secondary Desktop
        "misterio@maia" = mkHome {
          username = "misterio";
          hostname = "maia";
          persistence = true;

          colorscheme = "dracula";
        };
        # Raspi 4
        "misterio@merope" = mkHome {
          username = "misterio";
          hostname = "merope";
          persistence = true;

          colorscheme = "nord";
        };
        # VPS
        "misterio@electra" = mkHome {
          username = "misterio";
          hostname = "electra";
          persistence = true;

          colorscheme = "solarflare";
        };
        # For easy bootstraping from a nixos live usb
        "nixos@nixos" = mkHome {
          username = "nixos";
          hostname = "nixos";
          pkgs = legacyPackages.x86_64-linux;
          features = [ "desktop/gnome" ];
          persistence = false;
        };
      };

      deploy = {
        nodes = mkDeploys nixosConfigurations homeConfigurations;
        magicRollback = true;
        autoRollback = true;
      };

      deployChecks = { };
    };
}
