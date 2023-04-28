{ config, ... }:
let
  mkSimple = domain: {
    job_name = domain;
    scheme = "https";
    static_configs = [{ targets = [ domain ]; }];
    metrics_path = "/metrics";
  };
in {
  services = {
    prometheus = {
      enable = true;
      scrapeConfigs = [
        (mkSimple "hydra.m7.rs")
        (mkSimple "sitespeed.m7.rs")
        (mkSimple "alcyone.m7.rs")
        (mkSimple "celaeno.m7.rs")
        (mkSimple "merope.m7.rs")
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
