{ config, lib, persistence, ... }:
{
  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      dns = {
        baseDomain = "fontes.dev.br";
        magicDns = true;
        domains =  [ "ts.fontes.dev.br" ];
        nameservers = [
          "9.9.9.9"
        ];
      };
      port = 8085;
      serverUrl = "https://tailscale.fontes.dev.br";
      logLevel = "warn";
      settings = {
        logtail.enabled = false;
      };
    };

    nginx.virtualHosts = let
      location = "http://localhost:${toString config.services.headscale.port}";
    in {
      "tailscale.fontes.dev.br" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = location;
      };
      "tailscale.misterio.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = location;
      };
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [ "/var/lib/headscale" ];
  };
}
