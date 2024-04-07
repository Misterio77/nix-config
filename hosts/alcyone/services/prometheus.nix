{
  config,
  outputs,
  lib,
  ...
}:
{
  services = {
    prometheus = {
      enable = true;
      globalConfig = {
        # Scrape a bit more frequently
        scrape_interval = "30s";
      };
      scrapeConfigs = [
        {
          job_name = "hydra";
          scheme = "https";
          static_configs = [ { targets = [ "hydra.m7.rs" ]; } ];
        }
        {
          job_name = "headscale";
          scheme = "https";
          static_configs = [ { targets = [ "tailscale.m7.rs" ]; } ];
        }
        {
          job_name = "nginx";
          scheme = "https";
          static_configs = [
            {
              targets = [
                "alcyone.m7.rs"
                "celaeno.m7.rs"
                "merope.m7.rs"
              ];
            }
          ];
        }
        {
          job_name = "hosts";
          scheme = "http";
          static_configs = lib.mapAttrsToList (hostname: value: let
            port = value.config.services.prometheus.exporters.node.port;
          in {
            targets = ["${hostname}:${toString port}"];
            labels.instance = hostname;
          }) outputs.nixosConfigurations;
        }
      ];
      extraFlags =
        let
          prometheus = config.services.prometheus.package;
        in
        [
          # Custom consoles
          "--web.console.templates=${prometheus}/etc/prometheus/consoles"
          "--web.console.libraries=${prometheus}/etc/prometheus/console_libraries"
        ];
    };
    nginx.virtualHosts = {
      "metrics.m7.rs" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString config.services.prometheus.port}";
      };
    };
  };
}
