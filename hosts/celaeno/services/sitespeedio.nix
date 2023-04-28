{ config, inputs, pkgs, ... }: {
  services = {
    sitespeedio = {
      enable = true;
      period = "hourly";
      urls = [
        "https://m7.rs"
        "https://m7.rs/blog"
        "https://m7.rs/cv"
      ];
      settings = {
        graphite = {
          host = "localhost";
          port = config.services.prometheus.exporters.graphite.graphitePort;
        };
      };
    };

    prometheus.exporters.graphite = {
      enable = true;
      extraFlags = [ "--graphite.mapping-strict-match" ]; # Drop non-matched metrics
      mappingSettings.mappings = [
        # Page summaries
        {
          match = ''^sitespeed_io\.([^.]+)\.([^.]+)\.pageSummary\.([^.]+)\.([^.]+)\.([^.]+)\.([^.]+)\.(.+?)(?:\.(mean|max|median|min|p90|p99|p10|rsd|mdev|stddev|total|values))?$'';
          match_type = "regex";
          name = "sitespeedio_$7";
          labels = {
            profile = "$1";
            site = "$2";
            domain = "$3";
            page = "$4";
            browser = "$5";
            platform = "$6";
            # We save this so that we can drop specific aggregate metrics
            aggr_kind = "$8";
          };
        }
      ];
    };

    nginx.virtualHosts."sitespeed.m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "=/metrics".proxyPass = "http://localhost:${toString config.services.prometheus.exporters.graphite.port}";
        "/".root = config.services.sitespeedio.settings.outputFolder;
      };
    };
  };

  # ====================================
  # Apply nixpkgs#228542 patch
  disabledModules = [ "services/monitoring/prometheus/exporters.nix" ];
  imports = [ "${inputs.nixpkgs-228542}/nixos/modules/services/monitoring/prometheus/exporters.nix" ];
  nixpkgs.overlays = [(final: prev: { prometheus-graphite-exporter = pkgs.inputs.nixpkgs-228542.prometheus-graphite-exporter; })];
  # ====================================
}
