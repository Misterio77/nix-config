{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.colorscheme;
  inherit (lib) types mkOption;

  hexColorPattern = "#([0-9a-fA-F]{3}){1,2}";
  isHexColor = c: lib.isString c && ((builtins.match hexColorPattern c) != null);
  hexColor = types.strMatching hexColorPattern;
  schemeTypes = ["content" "expressive" "fidelity" "fruit-salad" "monochrome" "neutral" "rainbow" "tonal-spot"];

  generate = source: let
    config = (pkgs.formats.toml {}).generate "config.toml" {
      templates = {};
      config = {
        colors_to_harmonize = let
          light-c = inputs.nix-colors.colorschemes.standardized-light.palette;
          dark-c = inputs.nix-colors.colorschemes.standardized-dark.palette;
        in {
          light-red = light-c.base08;
          light-orange = light-c.base09;
          light-yellow = light-c.base0A;
          light-green = light-c.base0B;
          light-cyan = light-c.base0C;
          light-blue = light-c.base0D;
          light-magenta = light-c.base0E;
          dark-red = dark-c.base08;
          dark-orange = dark-c.base09;
          dark-yellow = dark-c.base0A;
          dark-green = dark-c.base0B;
          dark-cyan = dark-c.base0C;
          dark-blue = dark-c.base0D;
          dark-magenta = dark-c.base0E;
        };
      };
    };
  in
    pkgs.runCommand "generate-theme" {} ''
      mkdir "$out" -p
      for type in ${lib.concatStringsSep " " schemeTypes}; do
        ${pkgs.inputs.matugen.default}/bin/matugen ${
        if (isHexColor source)
        then "color hex"
        else "image"
      } --config ${config} -j hex -t "scheme-$type" "${source}" > "$out/$type.json"
      done
    '';

  generated = lib.importJSON "${generate cfg.source}/${cfg.type}.json";
  removePrefixAttrs = prefix: attrs:
    lib.mapAttrs' (n: v: {
      name = lib.removePrefix prefix n;
      value = v;
    }) (lib.filterAttrs (n: _: lib.hasPrefix prefix n) attrs);
in {
  options.colorscheme = {
    source = mkOption {
      type = types.either types.path hexColor;
      # TODO: generate default from hostname
      # colorFromString = c: builtins.substring 0 6 (builtins.hashString "md5" c);
      default = "#2B3975";
    };
    mode = mkOption {
      type = types.enum ["dark" "light"];
      default = "dark";
    };
    type = mkOption {
      type = types.enum schemeTypes;
      default = "fruit-salad";
    };
    colors = mkOption {
      readOnly = true;
      type = types.attrsOf hexColor;
      default = generated.colors.${cfg.mode};
    };
    harmonized = mkOption {
      readOnly = true;
      type = types.attrsOf hexColor;
      default = removePrefixAttrs "${cfg.mode}-" generated.harmonized_colors;
    };
  };
}
