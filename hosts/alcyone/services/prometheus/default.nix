{ config, ... }:
let
  mkStatic = job_name: targets: {
    inherit job_name;
    scheme = "https";
    static_configs = [{ inherit targets; }];
    metrics_path = "/metrics";
  };
in {
  services = {
    prometheus = {
      enable = true;
      scrapeConfigs = [
        (mkStatic "hydra" ["hydra.m7.rs"])
        (mkStatic "sitespeed" ["sitespeed.m7.rs"])
        (mkStatic "nginx" ["alcyone.m7.rs" "celaeno.m7.rs" "merope.m7.rs"])
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
