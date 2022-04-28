{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:RiscadoA/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";

    utils.url = "github:numtide/flake-utils";

    paste-misterio-me = {
      url = "github:misterio77/paste.misterio.me/1.3.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "utils";
      };
    };
  };

  outputs = inputs:
    let
      overlay = import ./overlays;
      overlays = with inputs; [
        overlay
        nur.overlay
        paste-misterio-me.overlay
      ];
      lib = import ./lib { inherit inputs overlays; };
    in
    {
      inherit overlay overlays;

      nixosModules = lib.importAttrset ./modules/nixos;
      homeManagerModules = lib.importAttrset ./modules/home-manager;

      nixosConfigurations = {
        atlas = lib.mkSystem {
          hostname = "atlas";
          system = "x86_64-linux";
          users = [ "misterio" ];
        };
        pleione = lib.mkSystem {
          hostname = "pleione";
          system = "x86_64-linux";
          users = [ "misterio" ];
        };
        merope = lib.mkSystem {
          hostname = "merope";
          system = "aarch64-linux";
          users = [ "misterio" ];
        };
        maia = lib.mkSystem {
          hostname = "maia";
          system = "x86_64-linux";
          users = [ "layla" "misterio" ];
        };
      };

      homeConfigurations = {
        "misterio@atlas" = lib.mkHome {
          username = "misterio";
          system = "x86_64-linux";
          hostname = "atlas";

          graphical = true;
          trusted = true;
          colorscheme = "phd";
        };
        "misterio@pleione" = lib.mkHome {
          username = "misterio";
          system = "x86_64-linux";
          hostname = "pleione";

          graphical = true;
          trusted = true;
          colorscheme = "paraiso";
        };
        "misterio@merope" = lib.mkHome {
          username = "misterio";
          system = "aarch64-linux";
          hostname = "merope";

          colorscheme = "nord";
        };
        "misterio@maia" = lib.mkHome {
          username = "misterio";
          system = "x86_64-linux";
          hostname = "maia";

          colorscheme = "ashes";
        };

        "layla@maia" = lib.mkHome {
          username = "layla";
          hostname = "maia";
          system = "x86_64-linux";

          graphical = true;
          colorscheme = "dracula";
        };
      };

      templates = import ./templates;

    } // inputs.utils.lib.eachDefaultSystem (system:
      let
        inherit (inputs.nix-colors.lib { inherit pkgs; }) gtkThemeFromScheme;
        inherit (inputs.nix-colors) colorSchemes;
        inherit (builtins) mapAttrs;
        pkgs = import inputs.nixpkgs { inherit system overlays; };
      in
      {
        # Allows 'nix build .#package-name', including vanilla, overlayed, and custom packages
        packages = pkgs // {
          # Add custom generated gtk themes
          generated-gtk-themes = mapAttrs (_: scheme: gtkThemeFromScheme { inherit scheme; }) colorSchemes;
        };
        # 'nix develop' for bootstrapping
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ home-manager git ];
          NIX_CONFIG = "experimental-features = nix-command flakes";
        };
      });
}
