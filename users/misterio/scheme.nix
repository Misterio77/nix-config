{ pkgs, config, nix-colors, ... }:

let
  wallpaperFromScheme = scheme:
    "${pkgs.stdenv.mkDerivation {
      name = "generated-nix-wallpaper";
      src = pkgs.writeTextFile {
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
            <rect width="100%" height="100%" fill="#${scheme.colors.base01}"/>
            <g transform="translate(802.1 1222)">
                <path
                    id="path3336-6"
                    d="m309.55-710.39 122.2 211.68-56.157 0.5268-32.624-56.869-32.856 56.565-27.902-0.011-14.291-24.69 46.81-80.49-33.229-57.826z"
                    fill="#${scheme.colors.base0C}"
                    fill-rule="evenodd"/>
              <use transform="rotate(60,407.11,-715.79)" width="100%" height="100%" xlink:href="#path3336-6"/>
              <use transform="rotate(-60,407.31,-715.7)" width="100%" height="100%" xlink:href="#path3336-6"/>
              <use transform="rotate(180,407.42,-715.76)" width="100%" height="100%" xlink:href="#path3336-6"/>
              <path
                  id="path4260-0"
                  d="m309.55-710.39 122.2 211.68-56.157 0.5268-32.624-56.869-32.856 56.565-27.902-0.011-14.291-24.69 46.81-80.49-33.229-57.826z"
                  color="#000000"
                  color-rendering="auto"
                  fill="#${scheme.colors.base0D}"
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
      buildInputs = with pkgs; [ inkscape ];
      unpackPhase = "true";
      buildPhase = ''
        inkscape --export-type="png" $src -w 2560 -h 1080 -o wallpaper.png
      '';
      installPhase = "mkdir -p $out && cp wallpaper.png $out";
    }}/wallpaper.png";
  colorschemeFromPicture = picture: kind:
    import (pkgs.stdenv.mkDerivation {
      name = "generated-colorscheme";
      buildInputs = with pkgs; [ flavours ];
      unpackPhase = "true";
      buildPhase = ''
        template=$(cat <<-END
        {
          slug = "$(basename ${picture})-${kind}";
          name = "Generated";
          author = "{{scheme-author}}";
          colors = {
            base00 = "{{base00-hex}}";
            base01 = "{{base01-hex}}";
            base02 = "{{base02-hex}}";
            base03 = "{{base03-hex}}";
            base04 = "{{base04-hex}}";
            base05 = "{{base05-hex}}";
            base06 = "{{base06-hex}}";
            base07 = "{{base07-hex}}";
            base08 = "{{base08-hex}}";
            base09 = "{{base09-hex}}";
            base0A = "{{base0A-hex}}";
            base0B = "{{base0B-hex}}";
            base0C = "{{base0C-hex}}";
            base0D = "{{base0D-hex}}";
            base0E = "{{base0E-hex}}";
            base0F = "{{base0F-hex}}";
          };
        }
        END
        )

        flavours generate "${kind}" "${picture}" --stdout | \
        flavours build <( tee ) <( echo "$template" ) > default.nix
      '';
      installPhase = "mkdir -p $out && cp default.nix $out";
    });

    currentWallpaper = import ./current-wallpaper.nix;
    currentMode = import ./current-mode.nix;
    currentScheme = import ./current-scheme.nix;
in {
  colorscheme = if currentScheme != null
    then nix-colors.colorSchemes.${currentScheme}
    else colorschemeFromPicture config.wallpaper currentMode;
  wallpaper = if currentWallpaper != null
    then ../../wallpapers/${currentWallpaper}
    else wallpaperFromScheme config.colorscheme;
}
