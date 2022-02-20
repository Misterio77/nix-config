{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:misterio77/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";
    nur.url = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:RiscadoA/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";

    utils.url = "github:numtide/flake-utils";

    # Nixified projects (usually hosted on merope)
    paste-misterio-me.url = "github:misterio77/paste.misterio.me/1.3.0";
    paste-misterio-me.inputs.nixpkgs.follows = "nixpkgs";
    paste-misterio-me.inputs.utils.follows = "utils";
    pmis.url = "github:misterio77/pmis/1.0.1";
    pmis.inputs.nixpkgs.follows = "nixpkgs";
    pmis.inputs.utils.follows = "utils";
    sistemer-bot.url = "github:misterio77/sistemer-bot/1.1.4";
    sistemer-bot.inputs.nixpkgs.follows = "nixpkgs";
    sistemer-bot.inputs.utils.follows = "utils";
    disconic.url = "github:misterio77/disconic/0.2.1";
    disconic.inputs.nixpkgs.follows = "nixpkgs";
    disconic.inputs.utils.follows = "utils";
  };

  outputs = { ... }@inputs:
    let
      overlay = import ./overlays;
      overlays = with inputs; [
        overlay
        nur.overlay
        sistemer-bot.overlay
        paste-misterio-me.overlay
        pmis.overlay
        disconic.overlay
      ];
      lib = import ./lib { inherit inputs overlays; };
    in
    {
      inherit overlay overlays;

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
          colorscheme = "rose-pine-moon";
          wallpaper = "autumn-mountains";
        };
        "misterio@pleione" = lib.mkHome {
          username = "misterio";
          system = "x86_64-linux";
          hostname = "pleione";

          graphical = true;
          trusted = true;
          colorscheme = "paraiso";
          wallpaper = "eclipse-moon-red";
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
        pkgs = import inputs.nixpkgs { inherit system overlays; };
        home-manager = inputs.home-manager.defaultPackage."${system}";
        gtkThemeFromScheme = (inputs.nix-colors.lib { inherit pkgs; }).gtkThemeFromScheme;
        generated-gtk-themes = builtins.mapAttrs (name: value: gtkThemeFromScheme { scheme = value; }) inputs.nix-colors.colorSchemes;
      in
      {
        packages = pkgs // { inherit home-manager generated-gtk-themes; };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ nixUnstable nixfmt rnix-lsp home-manager git ];
        };
      });
}
