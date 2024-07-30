{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.colorscheme;
  inherit (lib) types mkOption;

  hexColor = types.strMatching "#([0-9a-fA-F]{3}){1,2}";

  removeFilterPrefixAttrs = prefix: attrs:
    lib.mapAttrs' (n: v: {
      name = lib.removePrefix prefix n;
      value = v;
    }) (lib.filterAttrs (n: _: lib.hasPrefix prefix n) attrs);

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
      type = types.enum (pkgs.generateColorscheme null null).schemeTypes;
      default = "content";
    };

    generatedDrv = mkOption {
      type = types.package;
      default = pkgs.generateColorscheme (cfg.source.name or "default") cfg.source;
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
    harmonized = mkOption {
      readOnly = true;
      type = types.attrsOf hexColor;
      default = removeFilterPrefixAttrs "${cfg.mode}-" cfg.rawColorscheme.harmonized_colors;
    };
  };
}
