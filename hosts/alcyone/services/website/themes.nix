{ inputs, pkgs, ... }:
let
  themes = pkgs.stdenv.mkDerivation {
    name = "website-themes";
    src = builtins.toFile "schemes" (builtins.toJSON inputs.nix-colors.colorSchemes);
    dontUnpack = true;
    buildInputs = [ pkgs.jq ];
    buildPhase = ''
      build_css() {
        scheme_name="$1"
        scheme=$(jq -r --arg scheme_name "$scheme_name" '.[$scheme_name]' $src)

        jq -r '"
      /* \(.name) by \(.author) */
      :root {
        --scheme-name: \"\(.name)\";
        --scheme-author: \"\(.author)\";
        --base00: #\(.colors.base00);
        --base01: #\(.colors.base01);
        --base02: #\(.colors.base02);
        --base03: #\(.colors.base03);
        --base04: #\(.colors.base04);
        --base05: #\(.colors.base05);
        --base06: #\(.colors.base06);
        --base07: #\(.colors.base07);
        --base08: #\(.colors.base08);
        --base09: #\(.colors.base09);
        --base0A: #\(.colors.base0A);
        --base0B: #\(.colors.base0B);
        --base0C: #\(.colors.base0C);
        --base0D: #\(.colors.base0D);
        --base0E: #\(.colors.base0E);
        --base0F: #\(.colors.base0F);
      }
        "' <<< "$scheme" > "$scheme_name.css"
      }

      for scheme_name in $(jq -r 'keys[]' $src); do
        build_css "$scheme_name" &
      done

      wait
    '';
    installPhase = ''
      mkdir $out
      cp $src $out/themes.json
      cp *.css $out/
    '';
  };
  days = n: toString (n * 60 * 60 * 24);
in
{
  services.nginx.virtualHosts = {
    "colors.m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          root = themes;
          extraConfig = ''
            add_header Access-Control-Allow-Origin *;
            add_header Cache-Control "max-age=${days 30}";
          '';
        };
      };
    };
  };
}
