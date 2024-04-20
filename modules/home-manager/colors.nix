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

  cfgFormat = pkgs.formats.toml {};
  generate = {
    source,
    type ? "tonal-spot",
    colorsToHarmonize ? let
      c = inputs.nix-colors.colorschemes."standardized-${cfg.mode}".palette;
    in {
      red = c.base08;
      orange = c.base09;
      yellow = c.base0A;
      green = c.base0B;
      cyan = c.base0C;
      blue = c.base0D;
      magenta = c.base0E;
    },
  }:
    lib.importJSON (pkgs.runCommand "generate-theme" {} ''
      ${pkgs.inputs.matugen.default}/bin/matugen ${
        if (isHexColor source)
        then "color hex"
        else "image"
      } --config ${
        cfgFormat.generate "config.toml" {
          templates = {};
          config = {colors_to_harmonize = colorsToHarmonize;};
        }
      } -j hex -t "scheme-${type}" "${source}" > $out
    '');

  generated = generate {inherit (cfg) source type;};
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
      type = types.enum [
        "content"
        "expressive"
        "fidelity"
        "fruit-salad"
        "monochrome"
        "neutral"
        "rainbow"
        "tonal-spot"
      ];
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
      default = generated.harmonized_colors;
    };
  };
}
