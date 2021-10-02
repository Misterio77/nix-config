{ pkgs, config, ... }:

let
  colorscheme = config.nix-colors.colorscheme;
  colors = colorscheme.colors;
in {
  home.packages = with pkgs; [ element-desktop ];
  home.persistence."/data/home/misterio".directories = [ ".config/Element" ];
  xdg.configFile."Element/config.json".text = ''
    {
      "settingDefaults": {
        "default_theme": "custom-base16",
        "custom_themes": [
          {
            "name": "base16",
            "is_dark": ${pkgs.lib.boolToString (colorscheme.kind == "dark")},
            "colors": {
              "accent-color": "#${colors.base0B}",
              "primary-color": "#${colors.base0C}",
              "warning-color": "#${colors.base08}",
              "sidebar-color": "#${colors.base00}",
              "roomlist-background-color": "#${colors.base01}",
              "roomlist-text-color": "#${colors.base0A}",
              "roomlist-text-secondary-color": "#${colors.base05}",
              "roomlist-highlights-color": "#${colors.base00}",
              "roomlist-separator-color": "#${colors.base02}",
              "timeline-background-color": "#${colors.base02}",
              "timeline-text-color": "#${colors.base06}",
              "timeline-text-secondary-color": "#${colors.base0D}",
              "timeline-highlights-color": "#${colors.base01}",
              "reaction-row-button-selected-bg-color": "#${colors.base08}"
            }
          }
        ]
      },
      "showLabsSettings": true
    }
  '';
}
