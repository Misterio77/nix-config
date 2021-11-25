{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    declarative-cachix.url = "github:jonascarpay/declarative-cachix";
    impermanence.url = "github:RiscadoA/impermanence";

    nix-colors.url = "github:Misterio77/nix-colors";

    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Projects being worked on
    projeto-bd = {
      # url = "sourcehut:~misterio/BSI-SCC0540-projeto";
      url = "git+https://git.sr.ht/~misterio/BSI-SCC0540-projeto?ref=main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "utils";
      };
    };

  };

  outputs =
    { nixpkgs
    , hardware
    , home-manager
    , nur
    , declarative-cachix
    , impermanence
    , nix-colors
    , utils
      # Projects
    , projeto-bd
    , ...
    }:
    let
      # My overlays, plus from external projects
      overlay = (import ./overlays);
      overlays = [
        overlay
        projeto-bd.overlay
      ];

      # Make system configuration, given hostname and system type
      mkSystem = { hostname, system }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit nixpkgs hardware nur declarative-cachix
              impermanence nix-colors system projeto-bd;
          };
          modules = [ (./hosts + "/${hostname}") ./modules/nixos { nixpkgs.overlays = overlays; } ];
        };
      # Make home configuration, given username, required features, and system type
      mkHome = { username, features, system, hostname }:
        home-manager.lib.homeManagerConfiguration {
          inherit username system;
          extraSpecialArgs = {
            inherit nur impermanence nix-colors features projeto-bd hostname;
          };
          configuration = ./users + "/${username}";
          extraModules = [ ./modules/home-manager { nixpkgs.overlays = overlays; } ];
          homeDirectory = "/home/${username}";
        };
    in
    {
      inherit overlay overlays;

      nixosConfigurations = {
        # Main PC
        atlas = mkSystem {
          hostname = "atlas";
          system = "x86_64-linux";
        };
        # Laptop
        pleione = mkSystem {
          hostname = "pleione";
          system = "x86_64-linux";
        };
        # Raspberry Pi 4B
        merope = mkSystem {
          hostname = "merope";
          system = "aarch64-linux";
        };
        # Gf's PC
        maia = mkSystem {
          hostname = "maia";
          system = "x86_64-linux";
        };
      };

      homeConfigurations = {
        "misterio@atlas" = mkHome {
          username = "misterio";
          hostname = "atlas";
          features = [ "cli" "games" "desktop-sway" "trusted" "persistence" "mining" "rgb" ];
          system = "x86_64-linux";
        };
        "misterio@pleione" = mkHome {
          username = "misterio";
          hostname = "pleione";
          features = [ "cli" "games" "desktop-sway" "trusted" "persistence" ];
          system = "x86_64-linux";
        };
        "misterio@merope" = mkHome {
          username = "misterio";
          hostname = "merope";
          features = [ "cli" "persistence" ];
          system = "aarch64-linux";
        };
        "misterio@maia" = mkHome {
          username = "misterio";
          hostname = "maia";
          features = [ "cli" "persistence" ];
          system = "x86_64-linux";
        };

        "layla@maia" = mkHome {
          username = "layla";
          hostname = "maia";
          features = [ ];
          system = "x86_64-linux";
        };
      };

      templates = import ./templates;

    } // utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system overlays; };
    in
    {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [ nixUnstable nixfmt rnix-lsp ];
      };
    });
}
