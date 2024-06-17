{config, ...}: {
  sops.secrets = {
    grafana-gabriel-password = {
      sopsFile = ../../secrets.yaml;
      owner = "grafana";
    };
    grafana-mail-password = {
      sopsFile = ../../secrets.yaml;
      owner = "grafana";
    };
  };

  services = {
    grafana = {
      enable = true;
      settings = {
        server.http_port = 3000;
        users.default_theme = "system";
        dashboards.default_home_dashboard_path = "${./dashboards}/hosts.json";
        security = {
          admin_user = "gabriel";
          admin_email = "hi@m7.rs";
          admin_password = "$__file{${config.sops.secrets.grafana-gabriel-password.path}}";
          cookie_secure = true;
        };
        "auth.anonymous" = {
          enabled = true;
        };
        smtp = rec {
          enabled = true;
          host = "mail.m7.rs:465";
          from_address = user;
          user = config.mailserver.loginAccounts."grafana@m7.rs".name;
          password = "$__file{${config.sops.secrets.grafana-mail-password.path}}";
        };
      };
      provision = {
        enable = true;
        dashboards.settings.providers = [{
          options.path = ./dashboards;
        }];
        datasources.settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "https://metrics.m7.rs";
              isDefault = true;
            }
          ];
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
