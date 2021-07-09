{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.colorscheme;
in {
  options.colorscheme = {
    slug = mkOption {
      type = types.str;
      default = "";
      description = ''
        Color scheme slug (sanitized name)
      '';
    };
    name = mkOption {
      type = types.str;
      default = "";
      description = ''
        Color scheme (pretty) name
      '';
    };
    author = mkOption {
      type = types.str;
      default = "";
      description = ''
        Color scheme author
      '';
    };

    colors =
      let
        mkColorOption = name: {
          inherit name;
          value = mkOption {
            type = types.strMatching "[a-fA-F0-9]{6}";
            description = "Color ${name}.";
          };
        };
      in
      listToAttrs (map mkColorOption [
        "base00" "base01" "base02" "base03"
        "base04" "base05" "base06" "base07"
        "base08" "base09" "base0A" "base0B"
        "base0C" "base0D" "base0E" "base0F"
      ]);
  };
}
