{ config, ... }: {
  services = {
    prometheus = {
      enable = true;
      scrapeConfigs = [
        {
          job_name = "sitespeed";
          scheme = "https";
          static_configs = [{
            targets = [ "sitespeed.m7.rs" ];
          }];
        }
      ];
      extraFlags = let
        prometheus = config.services.prometheus.package;
      in [
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
