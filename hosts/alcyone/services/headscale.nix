{ config, lib, ... }:
{
  services = {
    headscale = {
      enable = true;
      port = 8085;
      address = "127.0.0.1";
      settings = {
        dns_config = {
          override_local_dns = true;
          base_domain = "m7.rs";
          magic_dns = true;
          domains = [ "ts.m7.rs" ];
          nameservers = [
            "9.9.9.9"
          ];
        };
        server_url = "https://tailscale.m7.rs";
        metrics_listen_addr = "127.0.0.1:8095";
        logtail = {
          enabled = false;
        };
        log = {
          level = "warn";
        };
        ip_prefixes = [
          "100.64.0.0/10"
          "fdef:6567:bd7a::/48"
        ];
      };
    };

    nginx.virtualHosts = {
      "tailscale.m7.rs" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };
          "/metrics" = {
            proxyPass = "http://${config.services.headscale.settings.metrics_listen_addr}/metrics";
          };
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
