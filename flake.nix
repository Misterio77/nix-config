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
    sops-nix = {
      url = "github:mic92/sops-nix";
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
      url = "github:hyprwm/hyprland";
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

  outputs = inputs: rec {
    lib = import ./lib { inherit inputs; };

    overlays = {
      default = import ./overlay { inherit inputs; };
      nur = inputs.nur.overlay;
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

    devShells = lib.forAllSystems (system: {
      default = legacyPackages.${system}.callPackage ./shell.nix { };
    });

    legacyPackages = lib.forAllSystems (system:
      import inputs.nixpkgs {
        inherit system;
        overlays = builtins.attrValues overlays;
        config.allowUnfree = true;
      }
    );

    nixosConfigurations = {
      # Desktop
      atlas = lib.mkSystem {
        hostname = "atlas";
        pkgs = legacyPackages."x86_64-linux";
        persistence = true;
      };
      # Laptop
      pleione = lib.mkSystem {
        hostname = "pleione";
        pkgs = legacyPackages."x86_64-linux";
        persistence = true;
      };
      # Secondary Desktop
      maia = lib.mkSystem {
        hostname = "maia";
        pkgs = legacyPackages."x86_64-linux";
        persistence = true;
      };
      # Raspi 4
      merope = lib.mkSystem {
        hostname = "merope";
        pkgs = legacyPackages."aarch64-linux";
        persistence = true;
      };
      # VPS
      electra = lib.mkSystem {
        hostname = "electra";
        pkgs = legacyPackages."x86_64-linux";
        persistence = true;
      };
    };

    homeConfigurations = {
      # Desktop
      "misterio@atlas" = lib.mkHome {
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
      "misterio@pleione" = lib.mkHome {
        username = "misterio";
        hostname = "pleione";
        persistence = true;

        features = [
          "desktop/hyprland"
          "trusted"
          "laptop"
          "games"
        ];
        wallpaper = "castle-sunset-fantasy";
        colorscheme = "darkmoss";
      };
      # Secondary Desktop
      "misterio@maia" = lib.mkHome {
        username = "misterio";
        hostname = "maia";
        persistence = true;

        colorscheme = "dracula";
      };
      # Raspi 4
      "misterio@merope" = lib.mkHome {
        username = "misterio";
        hostname = "merope";
        persistence = true;

        colorscheme = "nord";
      };
      # VPS
      "misterio@electra" = lib.mkHome {
        username = "misterio";
        hostname = "electra";
        persistence = true;

        colorscheme = "solarflare";
      };
      # For easy bootstraping from a nixos live usb
      "nixos@nixos" = lib.mkHome {
        username = "nixos";
        hostname = "nixos";
        pkgs = legacyPackages.x86_64-linux;
        features = [ "desktop/gnome" ];
        persistence = false;
      };
    };

    hydraJobs = rec {
      nixos = builtins.mapAttrs lib.mkNixosJob nixosConfigurations;
      all = lib.mkAggregateJob { inherit nixos; };
    };

    nixConfig = {
      extra-substituers = [ "https://cache.m7.rs" ];
      extra-trusted-public-keys = [ "cache.m7.rs:kszZ/NSwE/TjhOcPPQ16IuUiuRSisdiIwhKZCxguaWg=" ];
    };
  };
}
