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
  services = {
    nginx.virtualHosts = {
      "misterio.me" = {
        default = true;
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "${pkgs.misterio-me.website}/public";
          extraConfig = ''
            add_header Last-Modified "${toDateTime inputs.misterio-me.lastModified}";
          '';
        };
      };
      "fontes.dev.br" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          return = "302 https://misterio.me$request_uri";
        };
      };
    };
    # Gemini
    agate = {
      enable = true;
      contentDir = "${pkgs.misterio-me.website}/public";
      hostnames = [ "misterio.me" ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 1965 ];
}
