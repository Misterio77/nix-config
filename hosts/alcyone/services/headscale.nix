{ config, lib, ... }:
{
  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      settings = {
        dns_config = {
          base_domain = "m7.rs";
          magic_dns = true;
          domains = [ "ts.m7.rs" ];
          nameservers = [
            "9.9.9.9"
          ];
        };
        server_url = "https://tailscale.m7.rs";
      };
      port = 8085;
      settings = {
        logtail.enabled = false;
        log.level = "warn";
      };
    };

    nginx.virtualHosts = {
      "tailscale.m7.rs" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.headscale.port}";
          proxyWebsockets = true;
        };
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
