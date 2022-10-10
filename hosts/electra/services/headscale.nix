{ config, lib, ... }:
{
  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      dns = {
        baseDomain = "m7.rs";
        magicDns = true;
        domains = [ "ts.m7.rs" ];
        nameservers = [
          "9.9.9.9"
        ];
      };
      port = 8085;
      serverUrl = "https://tailscale.m7.rs";
      logLevel = "warn";
      settings = {
        logtail.enabled = false;
      };
    };

    nginx.virtualHosts = {
      "tailscale.m7.rs" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass =
          "http://localhost:${toString config.services.headscale.port}";
      };
      "tailscale.misterio.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/".return = "302 https://tailscale.m7.rs$request_uri";
      };
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  environment.persistence = {
    "/persist".directories = [ "/var/lib/headscale" ];
  };
}
