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
    locations."/".return = "302 https://gsfontes.com$request_uri";
  };

  website = inputs.website.packages.${pkgs.system}.main;
  websiteLastModified = toDateTime inputs.website.lastModified;
in
{
  services = {
    nginx.virtualHosts = {
      "m7.rs" = redir;
      "misterio.me" = redir;
      "fontes.dev.br" = redir;
      "gsfontes.com" = {
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
          "/assets" = {
            root = "${website}/public";
            extraConfig = ''
              add_header Last-Modified "${websiteLastModified}";
              add_header Cache-Control max-age="${toString (30 * 60 * 60 * 24 /*  One month */)}";
            '';
          };
        };
      };
    };
    # Gemini
    agate = {
      enable = true;
      contentDir = pkgs.linkFarm "agate-website" [
        {
          name = "misterio.me";
          path = "${website}/public";
        }
        {
          name = "fontes.dev.br";
          path = "${website}/public";
        }
        {
          name = "m7.rs";
          path = "${website}/public";
        }
        {
          name = "gsfontes.com";
          path = "${website}/public";
        }
      ];
      hostnames = [ "misterio.me" "fontes.dev.br" "m7.rs" "gsfontes.com" ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 1965 ];
}
