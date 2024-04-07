{
  inputs,
  pkgs,
  ...
}: let
  themes = pkgs.stdenv.mkDerivation {
    name = "website-themes";
    src = builtins.toFile "schemes" (builtins.toJSON inputs.nix-colors.colorSchemes);
    dontUnpack = true;
    buildInputs = [pkgs.jq];
    buildPhase = ''
      build_css() {
        scheme_name="$1"
        scheme=$(jq -r --arg scheme_name "$scheme_name" '.[$scheme_name]' $src)

        jq -r '"
      /* \(.name) by \(.author) */
      :root {
        --scheme-name: \"\(.name)\";
        --scheme-author: \"\(.author)\";
        --base00: #\(.palette.base00);
        --base01: #\(.palette.base01);
        --base02: #\(.palette.base02);
        --base03: #\(.palette.base03);
        --base04: #\(.palette.base04);
        --base05: #\(.palette.base05);
        --base06: #\(.palette.base06);
        --base07: #\(.palette.base07);
        --base08: #\(.palette.base08);
        --base09: #\(.palette.base09);
        --base0A: #\(.palette.base0A);
        --base0B: #\(.palette.base0B);
        --base0C: #\(.palette.base0C);
        --base0D: #\(.palette.base0D);
        --base0E: #\(.palette.base0E);
        --base0F: #\(.palette.base0F);
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
in {
  services.nginx.virtualHosts = {
    "m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/colors/" = {
          alias = "${themes}/";
          extraConfig = ''
            add_header Access-Control-Allow-Origin *;
            add_header Cache-Control "max-age=${days 1}, stale-while-revalidate=${days 365}";
          '';
        };
      };
    };
    "colors.m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations."/".return = "301 https://m7.rs/colors$request_uri";
    };
  };
}
