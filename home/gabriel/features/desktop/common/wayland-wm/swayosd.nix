{pkgs, config, ...}: let
  inherit (config.colorscheme) colors;
in {
  services.swayosd = {
    enable = true;
    stylePath = pkgs.writeText "style.css" ''
      window {
        padding: 0 1em;
        border: 10em;
        border-radius: 10em;
        background-color: ${colors.surface};
        opacity: 0.7;
      }
      #container {
        margin: 1em;
      }

      image {
        color: ${colors.primary};
        opacity: 0.9;
      }
      image:disabled {
        color: ${colors.on_surface};
        opacity: 0.8;
      }
      label {
        color: ${colors.on_surface};
        opacity: 1;
      }

      progress {
        min-height: inherit;
        border-radius: inherit;
        border: none;
        background-color: ${colors.on_surface};
        opacity: 0.9;
      }
      progressbar {
        min-height: 0.5em;
        border-radius: 100em;
        background-color: transparent;
        border: none;
        opacity: 0.9;
      }
      progressbar:disabled {
        opacity: 0.5;
      }

      trough {
        min-height: inherit;
        border-radius: inherit;
        border: none;
        background-color: ${colors.on_surface};
        opacity: 1;
      }
    '';
  };
}
