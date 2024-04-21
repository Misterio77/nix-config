{
  inputs,
  outputs,
}: let
  inherit (inputs.nixpkgs.lib) filterAttrs mapAttrs elem;

  notBroken = pkg: !(pkg.meta.broken or false);
  isDistributable = pkg: (pkg.meta.license or {redistributable = true;}).redistributable;
  hasPlatform = sys: pkg: elem sys (pkg.meta.platforms or []);
  filterValidPkgs = sys: pkgs: filterAttrs (_: pkg: hasPlatform sys pkg && notBroken pkg && isDistributable pkg) pkgs;
in {
  pkgs = mapAttrs filterValidPkgs outputs.packages;
  wallpapers = mapAttrs (_: v: v.wallpapers) outputs.packages;
  colorschemes = mapAttrs (_: v: v.colorschemes) outputs.packages;
  hosts = mapAttrs (_: cfg: cfg.config.system.build.toplevel) outputs.nixosConfigurations;
}
