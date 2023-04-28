{ config, ... }:
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
          static_configs = [{
            targets = [ "hydra.m7.rs" ];
          }];
        }
        {
          job_name = "nginx";
          static_configs =[{
            targets = [ "alcyone.m7.rs" "celaeno.m7.rs" "merope.m7.rs" ];
          }];
        }
        {
          job_name = "sitespeed";
          static_configs = [{
            targets = [ "sitespeed.m7.rs" ];
          }];
          metric_relabel_configs = [
            # Only keep metrics that are not aggregations or are medians
            {
              source_labels = [ "aggr_kind" ];
              regex = "(median|)";
              action = "keep";
            }
            # Then remove the aggregation label
            {
              regex = "aggr_kind";
              action = "labeldrop";
            }
          ];
        }
      ];
      extraFlags = let prometheus = config.services.prometheus.package;
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
        locations."/".proxyPass =
          "http://localhost:${toString config.services.prometheus.port}";
      };
    };
  };
}
