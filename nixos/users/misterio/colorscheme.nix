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
    colors = {
      base00 = mkOption {
        type = types.str;
        default = "";
        description = ''
          Default background
        '';
      };
      base01 = mkOption {
        type = types.str;
        default = "";
        description = ''
          Lighter background
          (Status bars, line numbers and folding marks)
        '';
      };
      base02 = mkOption {
        type = types.str;
        default = "";
        description = ''
          Selection background
        '';
      };
      base03 = mkOption {
        type = types.str;
        default = "";
        description = ''
          Comments, Invisibles, Line Highlighting
        '';
      };
      base04 = mkOption {
        type = types.str;
        default = "";
        description = ''
          Dark Foreground (Used for status bars)
        '';
      };
      base05 = mkOption {
        type = types.str;
        default = "";
        description = ''
          Default Foreground, Caret, Delimiters, Operators
        '';
      };
      base06 = mkOption {
        type = types.str;
        default = "";
        description = ''
          Light Foreground (Not often used)
        '';
      };
      base07 = mkOption {
        type = types.str;
        default = "";
        description = ''
          Light Background (Not often used)
        '';
      };
      base08 = mkOption {
        type = types.str;
        default = "";
        description = ''
          Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
        '';
      };
      base09 = mkOption {
        type = types.str;
        default = "";
        description = ''
          Integers, Boolean, Constants, XML Attributes, Markup Link Url
        '';
      };
      base0A = mkOption {
        type = types.str;
        default = "";
        description = ''
          Classes, Markup Bold, Search Text Background
        '';
      };
      base0B = mkOption {
        type = types.str;
        default = "";
        description = ''
          Strings, Inherited Class, Markup Code, Diff Inserted
        '';
      };
      base0C = mkOption {
        type = types.str;
        default = "";
        description = ''
          Support, Regular Expressions, Escape Characters, Markup Quotes
        '';
      };
      base0D = mkOption {
        type = types.str;
        default = "";
        description = ''
          Function, Methods, Attribute IDs, Headings
        '';
      };
      base0E = mkOption {
        type = types.str;
        default = "";
        description = ''
          Keywords, Storage, Selector, Markup Italic, Diff Changed
        '';
      };
      base0F = mkOption {
        type = types.str;
        default = "";
        description = ''
          Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
        '';
      };
    };
  };
}
