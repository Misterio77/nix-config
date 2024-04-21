{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.colorscheme;
  inherit (lib) types mkOption;

  hexColor = types.strMatching "#([0-9a-fA-F]{3}){1,2}";
  schemeTypes = ["content" "expressive" "fidelity" "fruit-salad" "monochrome" "neutral" "rainbow" "tonal-spot"];

  removeFilterPrefixAttrs = prefix: attrs:
    lib.mapAttrs' (n: v: {
      name = lib.removePrefix prefix n;
      value = v;
    }) (lib.filterAttrs (n: _: lib.hasPrefix prefix n) attrs);

  rawColorscheme = lib.importJSON "${cfg.generatedDrv}/${cfg.type}.json";
in {
  options.colorscheme = {
    source = mkOption {
      type = types.either types.path hexColor;
      # TODO: generate default from hostname
      # colorFromString = c: builtins.substring 0 6 (builtins.hashString "md5" c);
      default = if config.wallpaper != null then config.wallpaper else "#2B3975";
    };
    mode = mkOption {
      type = types.enum ["dark" "light"];
      default = "dark";
    };
    type = mkOption {
      type = types.enum schemeTypes;
      default = "fruit-salad";
    };

    generatedDrv = mkOption {
      readOnly = true;
      type = types.package;
      default = pkgs.colorschemes.generateColorschemes (cfg.source.pname or cfg.source) cfg.source;
    };
    colors = mkOption {
      readOnly = true;
      type = types.attrsOf hexColor;
      default = rawColorscheme.colors.${cfg.mode};
    };
    harmonized = mkOption {
      readOnly = true;
      type = types.attrsOf hexColor;
      default = removeFilterPrefixAttrs "${cfg.mode}-" rawColorscheme.harmonized_colors;
    };
  };
}
