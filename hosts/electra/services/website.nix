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
            root = "${pkgs.website.main}/public";
            extraConfig = ''
              add_header Last-Modified "${toDateTime inputs.website.lastModified}";
              add_header Cache-Control max-age="${toString (60 * 60 * 24 /*  One day */)}";
            '';
          };
          "/assets" = {
            root = "${pkgs.website.main}/public";
            extraConfig = ''
              add_header Last-Modified "${toDateTime inputs.website.lastModified}";
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
          path = "${pkgs.website.main}/public";
        }
        {
          name = "fontes.dev.br";
          path = "${pkgs.website.main}/public";
        }
        {
          name = "m7.rs";
          path = "${pkgs.website.main}/public";
        }
        {
          name = "gsfontes.com";
          path = "${pkgs.website.main}/public";
        }
      ];
      hostnames = [ "misterio.me" "fontes.dev.br" "m7.rs" "gsfontes.com" ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 1965 ];
}
