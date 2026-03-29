{
  config,
  ...
}: let
  derpPort = 3478;
in {
  services = {
    headscale = {
      enable = true;
      port = 8085;
      address = "127.0.0.1";
      settings = {
        dns = {
          override_local_dns = true;
          base_domain = "ts.m7.rs";
          magic_dns = true;
          nameservers.global = ["9.9.9.9"];
          extra_records = [
            # My home ISP router does not support NAT Hairpin
            # Usually this shouldn't be a problem, because IPv6 works perfectly.
            # A few devices might not support IPv6 for one reason or another
            # So let's override the IPv4 DNS with my home servers tailnet IP
            {
              name = "merope.m7.rs";
              type = "A";
              value = "100.77.0.5";
            }
            {
              name = "media.m7.rs";
              type = "A";
              value = "100.77.0.5";
            }
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
        prefixes = {
          v4 = "100.77.0.0/24";
          v6 = "fd7a:115c:a1e0:77::/64";
        };
        derp.server = {
          enable = true;
          region_id = 999;
          stun_listen_addr = "0.0.0.0:${toString derpPort}";
        };
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

  # Derp server
  networking.firewall.allowedUDPPorts = [derpPort];

  environment.systemPackages = [config.services.headscale.package];

  environment.persistence = {
    "/persist".directories = [{
      directory = "/var/lib/headscale";
      user = config.services.headscale.user;
      group = config.services.headscale.group;
      mode = "0700";
    }];
  };
}
