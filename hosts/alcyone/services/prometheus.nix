{ config, ... }: {
  services = {
    prometheus = {
      enable = true;
    };
    nginx.virtualHosts = {
      "metrics.m7.rs" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${config.services.prometheus.port}";
      };
    };
  };
}
