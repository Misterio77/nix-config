{ config, lib, ... }:
{
  services = {
    headscale = {
      enable = true;
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
      port = 8085;
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
