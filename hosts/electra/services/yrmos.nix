{ inputs, pkgs, ... }:
let
  toDateTime = timestamp: builtins.readFile (
    pkgs.runCommandLocal "datetime" { } ''
      dt="$(date -Ru -d @${toString timestamp})"
      echo -n ''${dt/+0000/GMT} > $out
    ''
  );
  yrmosLastModified = toDateTime inputs.yrmos.lastModified;
  yrmos = inputs.yrmos.packages.${pkgs.system}.default;
in
{
  services.nginx.virtualHosts."yrmos.m7.rs" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "=/" = {
        return = "302 https://yrmos.m7.rs/rides";
      };
      "/" = {
        root = "${yrmos}/public";
        extraConfig = ''
          add_header Last-Modified "${yrmosLastModified}";
          add_header Cache-Control max-age="${toString (60 * 60 /*  One hour */)}";
          error_page 404 /404.html;
        '';
      };
    };
  };
}
