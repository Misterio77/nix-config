{ inputs, ... }:
let
  inherit (inputs) self home-manager nixpkgs;
  inherit (self) outputs;
in
rec {
  # Applies a function to a attrset's names, while keeping the values
  mapAttrNames = f: nixpkgs.lib.mapAttrs' (name: value: { name = f name; inherit value; });

  has = element: builtins.any (x: x == element);

  getUsername = string: builtins.elemAt (builtins.match "(.*)@(.*)" string) 0;
  getHostname = string: builtins.elemAt (builtins.match "(.*)@(.*)" string) 1;

  supportedSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
    "i686-linux"
  ];
  mainSystem = nixpkgs.lib.head supportedSystems;
  forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

  mkSystem =
    { hostname
    , pkgs
    , persistence ? false
    }:
    nixpkgs.lib.nixosSystem {
      inherit pkgs;
      specialArgs = {
        inherit inputs outputs hostname persistence;
      };
      modules = builtins.attrValues (import ../modules/nixos) ++ [ ../hosts/${hostname} ];
    };

  mkHome =
    { username
    , hostname ? null
    , pkgs ? outputs.nixosConfigurations.${hostname}.pkgs
    , persistence ? false
    , colorscheme ? null
    , wallpaper ? null
    , features ? [ ]
    }:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs outputs hostname username persistence
          colorscheme wallpaper features;
      };
      modules = builtins.attrValues (import ../modules/home-manager) ++ [ ../home/${username} ];
    };

  mkNixosJob = hostname: cfg: cfg.config.system.build.toplevel // {
    meta.description = "${hostname} NixOS system";
  };

  mkAggregateJob = jobs:
    outputs.legacyPackages.${mainSystem}.pkgs.releaseTools.aggregate {
      name = "all";
      constituents = nixpkgs.lib.collect builtins.isString (
        nixpkgs.lib.mapAttrsRecursiveCond
          (v: (v.type or null) != "derivation")
          (p: _: builtins.concatStringsSep "." p)
          jobs
      );
      meta.description = "All jobs";
    };
}
