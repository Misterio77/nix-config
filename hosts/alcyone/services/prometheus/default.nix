{ config, ... }: {
  services = {
    prometheus = {
      enable = true;
      scrapeConfigs = [{
        job_name = "sitespeed";
        scheme = "https";
        static_configs = [{
          targets = [ "sitespeed.m7.rs/metrics" ];
        }];
      }];
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
