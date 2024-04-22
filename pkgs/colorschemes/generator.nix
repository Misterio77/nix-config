{pkgs, ...}: let
  inherit (pkgs) lib;
  matugen = import (fetchTarball {
    url = "https://github.com/InioX/matugen/archive/3040fe974b94bc70b49e6c3b868a8eb1c7b294a3.tar.gz";
    sha256 = "sha256:0v7np4294fzwxmgf7pjcxvky63lrq1ajim1b8ywbp47wy9k0pcgs";
  }) {inherit pkgs;};
  generateColorscheme = name: source: let
    schemeTypes = ["content" "expressive" "fidelity" "fruit-salad" "monochrome" "neutral" "rainbow" "tonal-spot"];
    isHexColor = c: lib.isString c && (builtins.match "#([0-9a-fA-F]{3}){1,2}" c) != null;

    config = (pkgs.formats.toml {}).generate "config.toml" {
      templates = {};
      config = {
        colors_to_harmonize = {
          light-red = "#d03e3e";
          light-orange = "#d7691d";
          light-yellow = "#ad8200";
          light-green = "#31861f";
          light-cyan = "#00998f";
          light-blue = "#3173c5";
          light-magenta = "#9e57c2";
          dark-red = "#e15d67";
          dark-orange = "#fc804e";
          dark-yellow = "#e1b31a";
          dark-green = "#5db129";
          dark-cyan = "#21c992";
          dark-blue = "#00a3f2";
          dark-magenta = "#b46ee0";
        };
      };
    };
  in
    pkgs.runCommand "colorscheme-${name}" {
      # __contentAddressed = true;
      passthru = let
        drv = generateColorscheme name source;
      in {
        inherit schemeTypes;
        # Incurs IFD
        imported = lib.genAttrs schemeTypes (scheme: lib.importJSON "${drv}/${scheme}.json");
      };
    } ''
      mkdir "$out" -p
      for type in ${lib.concatStringsSep " " schemeTypes}; do
        ${matugen}/bin/matugen ${
        if (isHexColor source)
        then "color hex"
        else "image"
      } --config ${config} -j hex -t "scheme-$type" "${source}" > "$out/$type.json"
      done
    '';
in generateColorscheme
