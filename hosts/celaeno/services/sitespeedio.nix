{ config, inputs, pkgs, ... }:

{
  services = {
    sitespeedio = let
      settings = {
        browsertime = {
          iterations = 2;
          headless = true;
        };
        plugins.add = ["crawler"];
        crawler.depth = 4;
        graphite = {
          host = "localhost";
          port = config.services.prometheus.exporters.graphite.graphitePort;
        };
      };
    in {
      enable = true;
      period = "hourly";
      runs = [
        {
          inherit settings;
          urls = ["https://m7.rs"];
        }
        {
          inherit settings;
          urls = ["https://paste.misterio.me" "https://paste.misterio.me/u/misterio"];
        }
      ];
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
        {
          match = ''^sitespeed_io\.([^.]+)\.([^.]+)\.pageSummary\.([^.]+)\.([^.]+)\.([^.]+)\.([^.]+)(\..+?)?(?:\.(firstParty|thirdParty))?(?:\.contentTypes\.(json|css|font|html|image|javascript|svg))?(\..+?)?(?:\.(mean|max|median|min|p90|p99|p10|rsd|mdev|stddev|total|values))?$'';
          match_type = "regex";
          name = "sitespeedio$7$10";
          labels = {
            profile = "$1";
            site = "$2";
            domain = "$3";
            page = "$4";
            browser = "$5";
            platform = "$6";
            content_origin = "$8";
            content_type = "$9";
            aggr_kind = "$11";
          };
        }
      ];
    };

    nginx.virtualHosts."sitespeed.m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "=/metrics".proxyPass = "http://localhost:${toString config.services.prometheus.exporters.graphite.port}";
        "/".root = config.services.sitespeedio.dataDir;
      };
    };
  };

  # ====================================
  # Apply nixpkgs#228542 patch
  disabledModules = ["services/monitoring/prometheus/exporters.nix"];
  imports = ["${inputs.nixpkgs-228542}/nixos/modules/services/monitoring/prometheus/exporters.nix"];
  nixpkgs.overlays = [(final: prev: {prometheus-graphite-exporter = pkgs.inputs.nixpkgs-228542.prometheus-graphite-exporter;})];
  # ====================================
}
