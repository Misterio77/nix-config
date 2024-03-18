{
  description = "My NixOS configuration";

  nixConfig = {
    extra-substituters = [ "https://cache.m7.rs" ];
    extra-trusted-public-keys = [ "cache.m7.rs:kszZ/NSwE/TjhOcPPQ16IuUiuRSisdiIwhKZCxguaWg=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:misterio77/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefly = {
      url = "github:timhae/firefly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:viperml/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprwm-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disconic.url = "github:misterio77/disconic";
    website.url = "github:misterio77/website";
    paste-misterio-me.url = "github:misterio77/paste.misterio.me";
    yrmos.url = "github:misterio77/yrmos";
    awscli-console.url = "github:misterio77/awscli-console";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs systems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
    in
    {
      inherit lib;
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;
      templates = import ./templates;

      overlays = import ./overlays { inherit inputs outputs; };
      hydraJobs = import ./hydra.nix { inherit inputs outputs; };

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

      nixosConfigurations = {
        # Main desktop
        atlas =  lib.nixosSystem {
          modules = [ ./hosts/atlas ];
          specialArgs = { inherit inputs outputs; };
        };
        # Secondary desktop
        maia = lib.nixosSystem {
          modules = [ ./hosts/maia ];
          specialArgs = { inherit inputs outputs; };
        };
        # Personal laptop
        pleione = lib.nixosSystem {
          modules = [ ./hosts/pleione ];
          specialArgs = { inherit inputs outputs; };
        };
        # Work laptop
        electra = lib.nixosSystem {
          modules = [ ./hosts/electra ];
          specialArgs = { inherit inputs outputs; };
        };
        # Core server (Vultr)
        alcyone = lib.nixosSystem {
          modules = [ ./hosts/alcyone ];
          specialArgs = { inherit inputs outputs; };
        };
        # Build and game server (Oracle)
        celaeno = lib.nixosSystem {
          modules = [ ./hosts/celaeno ];
          specialArgs = { inherit inputs outputs; };
        };
        # Media server (RPi)
        merope = lib.nixosSystem {
          modules = [ ./hosts/merope ];
          specialArgs = { inherit inputs outputs; };
        };
      };

      homeConfigurations = {
        # Desktops
        "misterio@atlas" = lib.homeManagerConfiguration {
          modules = [ ./home/misterio/atlas.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "misterio@maia" = lib.homeManagerConfiguration {
          modules = [ ./home/misterio/maia.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "misterio@pleione" = lib.homeManagerConfiguration {
          modules = [ ./home/misterio/pleione.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "misterio@electra" = lib.homeManagerConfiguration {
          modules = [ ./home/misterio/electra.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "misterio@alcyone" = lib.homeManagerConfiguration {
          modules = [ ./home/misterio/alcyone.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "misterio@merope" = lib.homeManagerConfiguration {
          modules = [ ./home/misterio/merope.nix ];
          pkgs = pkgsFor.aarch64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "misterio@celaeno" = lib.homeManagerConfiguration {
          modules = [ ./home/misterio/celaeno.nix ];
          pkgs = pkgsFor.aarch64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "misterio@generic" = lib.homeManagerConfiguration {
          modules = [ ./home/misterio/generic.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
      };
    };
}
