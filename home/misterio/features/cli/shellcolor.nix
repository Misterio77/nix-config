{config, lib, ...}: let
  rmHash = lib.removePrefix "#";
  inherit (config.colorscheme) colors harmonized;
in {
  programs.shellcolor = {
    enable = true;
    settings = {
      base00 = "${rmHash colors.surface}"; # bg
      base05 = "${rmHash colors.on_surface}"; # fg

      base03 = "${rmHash colors.primary_container}"; # bright bg
      base07 = "${rmHash colors.on_primary_container}"; # bright fg

      base08 = "${rmHash harmonized.red}"; # red
      base0B = "${rmHash harmonized.green}"; # green
      base0A = "${rmHash harmonized.yellow}"; # yellow
      base0D = "${rmHash harmonized.blue}"; # blue
      base0E = "${rmHash harmonized.magenta}"; # magenta
      base0C = "${rmHash harmonized.cyan}"; # cyan

      base09 = "${rmHash colors.primary}"; # accent 1
      base0F = "${rmHash colors.error}"; # accent 2
      base01 = "${rmHash colors.surface_variant}"; # bg alt 1
      base04 = "${rmHash colors.on_surface_variant}"; # fg alt 1
      base02 = "${rmHash colors.tertiary_container}"; # bg alt 2
      base06 = "${rmHash colors.on_tertiary_container}"; # fg alt 2
    };
  };
}
