{ config, inputs, pkgs, ... }: {
  services = {
    sitespeedio = {
      enable = true;
      period = "*:0/10"; # Every ten minutes
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
      extraFlags = [
         # Drop non-matched metrics
        "--graphite.mapping-strict-match"
        # Keep samples for an hour
        "--graphite.sample-expiry=1h"
      ];
      mappingSettings.mappings = [
        # Page summaries
        {
          match = ''^sitespeed_io\.([^.]+)\.([^.]+)\.pageSummary\.([^.]+)\.([^.]+)\.([^.]+)\.([^.]+)(\..+?)?(?:\.(firstParty|thirdParty))?(\..+?)?(?:\.(css|font|html|image|javascript|svg))?(\..+?)?(?:\.(mean|max|median|min|p90|p99|p10|rsd|mdev|stddev|total|values))?$'';
          match_type = "regex";
          name = "sitespeedio$7$9$11";
          labels = {
            profile = "$1";
            site = "$2";
            domain = "$3";
            page = "$4";
            browser = "$5";
            platform = "$6";
            content_origin = "$8";
            content_type = "$10";
            aggr_kind = "$12";
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
