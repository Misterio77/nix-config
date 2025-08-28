{
  description = "My NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.m7.rs"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.m7.rs:kszZ/NSwE/TjhOcPPQ16IuUiuRSisdiIwhKZCxguaWg="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  inputs = {
    # Nix ecosystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    systems.url = "github:nix-systems/default-linux";

    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      # https://github.com/nix-community/impermanence/pull/272#discussion_r2230796215
      url = "github:misterio77/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-25_05.follows = "nixpkgs";
    };
    nix-gl = {
      url = "github:nix-community/nixgl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:misterio77/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Third party programs, packaged with nix
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      # url = "github:fufexan/nix-gaming";
      url = "github:misterio77/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # My own programs, packaged with nix
    themes = {
      url = "github:misterio77/themes";
      inputs.systems.follows = "systems";
    };
    disconic = {
      url = "github:misterio77/disconic";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    website = {
      url = "github:misterio77/website";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    paste-misterio-me = {
      url = "github:misterio77/paste.misterio.me";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    systems,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );
  in {
    inherit lib;
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    overlays = import ./overlays {inherit inputs outputs;};
    hydraJobs = import ./hydra.nix {inherit inputs outputs;};

    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
    devShells = forEachSystem (pkgs: import ./shell.nix {inherit pkgs;});
    formatter = forEachSystem (pkgs: pkgs.alejandra);

    nixosConfigurations = {
      # Main desktop
      atlas = lib.nixosSystem {
        modules = [./hosts/atlas];
        specialArgs = {
          inherit inputs outputs;
        };
      };
      # Personal laptop (Framework 13)
      maia = lib.nixosSystem {
        modules = [./hosts/maia];
        specialArgs = {
          inherit inputs outputs;
        };
      };
      # Core server (Vultr)
      alcyone = lib.nixosSystem {
        modules = [./hosts/alcyone];
        specialArgs = {
          inherit inputs outputs;
        };
      };
      # Build and game server (Oracle)
      celaeno = lib.nixosSystem {
        modules = [./hosts/celaeno];
        specialArgs = {
          inherit inputs outputs;
        };
      };
      # Build and game server (Magalu Cloud)
      taygeta = lib.nixosSystem {
        modules = [./hosts/taygeta];
        specialArgs = {
          inherit inputs outputs;
        };
      };
      # Media server (RPi)
      merope = lib.nixosSystem {
        modules = [./hosts/merope];
        specialArgs = {
          inherit inputs outputs;
        };
      };
    };

    # Standalone HM only
    homeConfigurations = {
      # Work laptop
      "gabriel@electra" = lib.homeManagerConfiguration {
        modules = [ ./home/gabriel/electra.nix ./home/gabriel/nixpkgs.nix ];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs;
        };
      };
    };
  };
}
