{ inputs, pkgs, ... }:
let
  toDateTime = timestamp: builtins.readFile (
    pkgs.runCommandLocal "datetime" { } ''
      dt="$(date -Ru -d @${toString timestamp})"
      echo -n ''${dt/+0000/GMT} > $out
    ''
  );
in
{
  services = let
    redir = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          return = "302 https://fontes.dev.br$request_uri";
        };
      };
  in {
    nginx.virtualHosts = {
      "misterio.me" = redir;
      "www.fontes.dev.br" = redir;
      "gabriel.fontes.dev.br" = redir;
      "fontes.dev.br" = {
        default = true;
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "${pkgs.website.main}/public";
          extraConfig = ''
            add_header Last-Modified "${toDateTime inputs.website.lastModified}";
            add_header Cache-Control max-age="${toString (60 * 60 * 24 /*  One day */)}";
          '';
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
      ];
      hostnames = [ "misterio.me" "fontes.dev.br" ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 1965 ];
}
