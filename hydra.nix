{
  inputs,
  outputs,
}: let
  inherit (inputs.nixpkgs) lib;

  notBroken = pkg: !(pkg.meta.broken or false);
  isDistributable = pkg: (pkg.meta.license or {redistributable = true;}).redistributable;
  hasPlatform = sys: pkg: lib.elem sys (pkg.meta.platforms or []);
  filterValidPkgs = sys: pkgs: lib.filterAttrs (_: pkg: hasPlatform sys pkg && notBroken pkg && isDistributable pkg) pkgs;

  getConfigTopLevel = (_: cfg: cfg.config.system.build.toplevel);
  mkAggregate = name: (
      system: packages: let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in
        pkgs.releaseTools.aggregate {
          inherit name;
          constituents = builtins.attrValues packages.${name};
        }
    );
in {
  pkgs = lib.mapAttrs filterValidPkgs outputs.packages;
  wallpapers = lib.mapAttrs (mkAggregate "wallpapers") outputs.packages;
  colorschemes = lib.mapAttrs (mkAggregate "wallpapers") outputs.packages;
  hosts = lib.mapAttrs getConfigTopLevel outputs.nixosConfigurations;
}
