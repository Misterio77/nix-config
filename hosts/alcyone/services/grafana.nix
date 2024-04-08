{config, ...}: {
  services = {
    grafana = {
      enable = true;
      settings.server.http_port = 3000;
      provision = {
        enable = true;
        datasources.settings = {
          apiVersion = 1;
          datasources = [{
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "https://metrics.m7.rs";
            isDefault = true;
          }];
        };
      };
    };
    nginx.virtualHosts = {
      "dash.m7.rs" = let
        port = config.services.grafana.settings.server.http_port;
      in {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString port}";
      };
    };
  };
}
