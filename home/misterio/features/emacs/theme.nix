{ emacsPackagesFor, writeText, config, ... }:
let
  emacsPackages = emacsPackagesFor config.programs.emacs.package;
  scheme = config.colorscheme;
in
emacsPackages.trivialBuild {
  pname = "theme";
  src = writeText "nix-${scheme.slug}.el" ''
    (require 'base16-theme)

    (defvar base16-${scheme.slug}-theme-colors
      '(:base00 "#${scheme.colors.base00}"
        :base01 "#${scheme.colors.base01}"
        :base02 "#${scheme.colors.base02}"
        :base03 "#${scheme.colors.base03}"
        :base04 "#${scheme.colors.base04}"
        :base05 "#${scheme.colors.base05}"
        :base06 "#${scheme.colors.base06}"
        :base07 "#${scheme.colors.base07}"
        :base08 "#${scheme.colors.base08}"
        :base09 "#${scheme.colors.base09}"
        :base0A "#${scheme.colors.base0A}"
        :base0B "#${scheme.colors.base0B}"
        :base0C "#${scheme.colors.base0C}"
        :base0D "#${scheme.colors.base0D}"
        :base0E "#${scheme.colors.base0E}"
        :base0F "#${scheme.colors.base0F}")
      "All colors for Base16 ${scheme.name} are defined here.")

    ;; Define the theme
    (deftheme base16-${scheme.slug})

    ;; Add all the faces to the theme
    (base16-theme-define 'base16-${scheme.slug} base16-${scheme.slug}-theme-colors)

    ;; Mark the theme as provided
    (provide-theme 'base16-${scheme.slug})

    (provide 'base16-${scheme.slug}-theme)
  '';
  packageRequires = [ emacsPackages.base16-theme ];
}
