{ config, lib, persistence, ... }:
{
  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      dns = {
        baseDomain = "misterio.me";
        magicDns = true;
        domains =  [ "ts.misterio.me" ];
        nameservers = [
          "9.9.9.9"
        ];
      };
      port = 8085;
      serverUrl = "https://tailscale.misterio.me";
    };

    nginx.virtualHosts = let
      location = "http://localhost:${toString config.services.headscale.port}";
    in {
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
