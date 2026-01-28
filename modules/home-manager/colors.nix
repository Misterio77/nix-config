{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  cfg = config.colorscheme;
  inherit (lib) types mkOption;

  hexColor = types.strMatching "#([0-9a-fA-F]{3}){1,2}";
in {
  options.colorscheme = {
    source = mkOption {
      type = types.either types.path hexColor;
      default =
        if config.wallpaper != null
        then config.wallpaper
        else "#2B3975";
    };
    mode = mkOption {
      type = types.enum ["dark" "light"];
      default = "dark";
    };
    type = mkOption {
      type = types.str;
      default = "rainbow";
    };

    generatedDrv = mkOption {
      type = types.package;
      default = pkgs.inputs.themes.generateColorscheme (cfg.source.name or "default") cfg.source;
    };
    rawColorscheme = mkOption {
      type = types.attrs;
      default = cfg.generatedDrv.imported.${cfg.type};
    };

    colors = mkOption {
      readOnly = true;
      type = types.attrsOf hexColor;
      default = cfg.rawColorscheme.colors.${cfg.mode};
    };

    # Gives access to other homes' colors
    hosts = mkOption {
      readOnly = true;
      type = types.attrs;
      default = let
        homeConfigs = lib.mapAttrs' (n: v: lib.nameValuePair (lib.last (lib.splitString "@" n)) v.config) outputs.homeConfigurations;
        nixosConfigs = lib.mapAttrs (_: v: v.config.home-manager.users.gabriel) outputs.nixosConfigurations;
      in
        lib.mapAttrs (_: v: v.colorscheme.rawColorscheme.colors.${cfg.mode}) (homeConfigs // nixosConfigs);
    };
  };
}
