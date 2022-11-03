{ inputs, pkgs, ... }:
let
  toDateTime = timestamp: builtins.readFile (
    pkgs.runCommandLocal "datetime" { } ''
      dt="$(date -Ru -d @${toString timestamp})"
      echo -n ''${dt/+0000/GMT} > $out
    ''
  );

  redir = {
    forceSSL = true;
    enableACME = true;
    locations."/".return = "302 https://m7.rs$request_uri";
  };

  websiteLastModified = toDateTime inputs.website.lastModified;
  website = inputs.website.packages.${pkgs.system}.main;

  themesLastModified = toDateTime inputs.nix-colors.lastModified;
  themes = pkgs.stdenv.mkDerivation {
    name = "website-themes";
    src = builtins.toFile "schemes" (builtins.toJSON inputs.nix-colors.colorSchemes);
    dontUnpack = true;
    buildInputs = [ pkgs.jq ];
    buildPhase = /* bash */ ''
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
      cp * $out/
    '';
  };
in
{
  services.nginx.virtualHosts = {
    "gsfontes.com" = redir;
    "misterio.me" = redir;
    "fontes.dev.br" = redir;
    "m7.rs" = {
      default = true;
      forceSSL = true;
      enableACME = true;
      locations = {
        # My key moved to openpgp.org
        "/7088C7421873E0DB97FF17C2245CAB70B4C225E9.asc" = {
          return = "301 https://keys.openpgp.org/vks/v1/by-fingerprint/7088C7421873E0DB97FF17C2245CAB70B4C225E9";
        };
        "/" = {
          root = "${website}/public";
          extraConfig = ''
            add_header Last-Modified "${websiteLastModified}";
            add_header Cache-Control max-age="${toString (60 * 60 * 24 /*  One day */)}";
          '';
        };
        "/assets/" = {
          root = "${website}/public";
          extraConfig = ''
            add_header Last-Modified "${websiteLastModified}";
            add_header Cache-Control max-age="${toString (30 * 60 * 60 * 24 /*  One month */)}";
          '';
        };
      };
    };
    "colors.m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          root = "${themes}";
          extraConfig = ''
            add_header Access-Control-Allow-Origin *;
            add_header Last-Modified "${themesLastModified}";
            add_header Cache-Control max-age="${toString (30 * 60 * 60 * 24 /*  One month */)}";
          '';
        };
      };
    };
  };
}
