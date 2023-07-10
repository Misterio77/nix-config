{
  description = "My NixOS configuration";

  nixConfig = {
    extra-substituters = [ "https://cache.m7.rs" ];
    extra-trusted-public-keys = [ "cache.m7.rs:kszZ/NSwE/TjhOcPPQ16IuUiuRSisdiIwhKZCxguaWg=" ];
  };

  inputs = {
    # Go back to nixos-unstable after PR 238700 is merged
    # https://nixpk.gs/pr-tracker.html?pr=238700
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";

    hardware.url = "github:nixos/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";
    sops-nix.url = "github:mic92/sops-nix";

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

    hyprland = {
      url = "github:hyprwm/hyprland/v0.25.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprwm-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disconic.url = "github:misterio77/disconic";
    website.url = "github:misterio77/website";
    paste-misterio-me.url = "github:misterio77/paste.misterio.me";
    yrmos.url = "github:misterio77/yrmos";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = nixpkgs.legacyPackages;
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

      wallpapers = import ./home/misterio/wallpapers;

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
