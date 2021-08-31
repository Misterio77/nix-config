{ lib, pkgs, config, ... }:
with lib;
let
  colorscheme = config.colorscheme;
  cfg = config.wallpaper;
  nix-wallpaper-template = { bg, fg1, fg2 }:
    pkgs.writeTextFile {
      name = "template.svg";
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <svg xmlns="http://www.w3.org/2000/svg"
            xmlns:cc="http://creativecommons.org/ns#"
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            width="2560"
            height="1080"
            version="1.1"
            viewBox="0 0 2400 1012.5">
          <rect width="100%" height="100%" fill="#${bg}"/>
          <g transform="translate(802.1 1222)">
              <path
                  id="path3336-6"
                  d="m309.55-710.39 122.2 211.68-56.157 0.5268-32.624-56.869-32.856 56.565-27.902-0.011-14.291-24.69 46.81-80.49-33.229-57.826z"
                  fill="#${fg1}"
                  fill-rule="evenodd"/>
            <use transform="rotate(60,407.11,-715.79)" width="100%" height="100%" xlink:href="#path3336-6"/>
            <use transform="rotate(-60,407.31,-715.7)" width="100%" height="100%" xlink:href="#path3336-6"/>
            <use transform="rotate(180,407.42,-715.76)" width="100%" height="100%" xlink:href="#path3336-6"/>
            <path 
                id="path4260-0"
                d="m309.55-710.39 122.2 211.68-56.157 0.5268-32.624-56.869-32.856 56.565-27.902-0.011-14.291-24.69 46.81-80.49-33.229-57.826z"
                color="#000000"
                color-rendering="auto"
                fill="#${fg2}"
                fill-rule="evenodd"
                image-rendering="auto"
                shape-rendering="auto"
                solid-color="#000000"
                style="isolation:auto;mix-blend-mode:normal"/>
            <use transform="rotate(120,407.34,-716.08)" width="100%" height="100%" xlink:href="#path4260-0"/>
            <use transform="rotate(240 407.29 -715.87)" width="100%" height="100%" xlink:href="#path4260-0"/>
          </g>
        </svg>
      '';
    };
in {
  options.wallpaper = {
    generate = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Generate wallpaper from color scheme?
      '';
    };
    path = mkOption {
      type = types.path;
      default = "";
      description = ''
        Wallpaper path
      '';
    };
  };

  config = let
    generated-nix-wallpaper = pkgs.stdenv.mkDerivation rec {
      name = "generated-nix-wallpaper";
      src = nix-wallpaper-template {
        bg = "${colorscheme.colors.base02}";
        fg1 = "${colorscheme.colors.base0C}";
        fg2 = "${colorscheme.colors.base0D}";
      };
      buildInputs = with pkgs; [ inkscape ];
      phases = [ "installPhase" ];
      installPhase = ''
        HOME=/build
        mkdir -p $out
        inkscape --export-type="png" ${src} -w 2560 -h 1080 -o $out/${colorscheme.slug}.png
      '';
    };
  in (mkIf cfg.generate {
    wallpaper.path = "${generated-nix-wallpaper}/${colorscheme.slug}.png";
  });
}
