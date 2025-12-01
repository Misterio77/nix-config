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
          datasources = [{
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "https://metrics.m7.rs";
            uid = "prometheus-default";
            isDefault = true;
          }];
        };
        alerting = {
          contactPoints.settings = {
            apiVersion = 1;
            contactPoints = [{
              name = "default";
              receivers = [{
                uid = "alerts-email";
                type = "email";
                settings.addresses = "<alerts@m7.rs>";
              }];
            }];
          };
          policies.settings = {
            apiVersion = 1;
            policies = [{
              receiver = "alerts-email";
              group_wait = "30s";
              group_interval = "5m";
              repeat_interval = "4h";
            }];
          };
          rules.settings = {
            apiVersion = 1;
            groups = [{
              name = "default";
              folder = "alerts";
              interval = "1m";
              orgId = 1;
              rules = [{
                title = "Low disk";
                uid = "low-disk-alert";
                notification_settings.receiver = "alerts-email";
                annotations = {
                  summary = "{{ $labels.instance }} is low on storage";
                  description = "{{ $labels.device }} at {{ $labels.instance }} is below 10% capacity.";
                };
                condition = "B";
                execErrState = "KeepLast";
                noDataState = "KeepLast";
                data = [
                  {
                    refId = "A";
                    datasourceUid = "prometheus-default";
                    model = {
                      refId = "A";
                      intervalMs = 1000;
                      expr = "avg by (device, instance) (node_filesystem_free_bytes / node_filesystem_size_bytes)";
                      instant = true;
                      range = false;
                      legendFormat = "__auto";
                      maxDataPoints = 43200;
                    };
                    relativeTimeRange = {
                      from = 600;
                      to = 0;
                    };
                  }
                  {
                    refId = "B";
                    datasourceUid = "__expr__";
                    model = {
                      refId = "B";
                      intervalMs = 1000;
                      maxDataPoints = 43200;
                      type = "threshold";
                      expression = "A";
                      datasource = {
                        type = "__expr__";
                        uid = "__expr__";
                      };
                      conditions = [{
                        type = "query";
                        query.params = ["B"];
                        evaluator = {
                          type = "lt";
                          params = [ 0.1 ];
                        };
                        operator.type = "and";
                        reducer.type = "last";
                      }];
                    };
                  }
                ];
              }];
            }];
          };
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
