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
      mappingSettings.mappings = [
        # Page summaries
        {
          match = ''sitespeed_io\.([^.]+)\.([^.]+)\.pageSummary\.([^.]+)\.([^.]+)\.([^.]+)\.([^.]+)\.(.*)'';
          match_type = "regex";
          name = "sitespeedio_$7";
          labels = {
            sitespeed_profile = "$1";
            sitespeed_job = "$2";
            domain = "$3";
            page = "$4";
            browser = "$5";
            platform = "$6";
          };
        }
        # Site summaries
        {
          match = ''sitespeed_io\.([^.]+)\.([^.]+)\.summary\.([^.]+)\.([^.]+)\.([^.]+)\.(.*)'';
          match_type = "regex";
          name = "sitespeedio_$6";
          labels = {
            sitespeed_profile = "$1";
            sitespeed_job = "$2";
            domain = "$3";
            page = "*";
            browser = "$4";
            platform = "$5";
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
