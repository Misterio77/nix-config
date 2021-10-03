{ pkgs, config, nix-colors, ... }:

let
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
in {
  # wallpaper.path = ../../wallpapers/mountain-pink-purple.jpg;
  # colorscheme = colorschemeFromPicture config.wallpaper.path "dark";
  colorscheme = nix-colors.colorSchemes.paraiso;
  wallpaper.generate = true;
}
