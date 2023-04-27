{ config, inputs, pkgs, ... }: {
  services = {
    sitespeedio = {
      enable = true;
      urls = [
        "https://m7.rs"
        "https://m7.rs/blog"
        "https://m7.rs/cv"
      ];
      period = "hourly";
      graphite = {
        enable = true;
        port = config.services.prometheus.exporters.graphite.graphitePort;
      };
    };

    prometheus.exporters.graphite.enable = true;

    nginx.virtualHosts."sitespeed.m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "=/metrics".proxyPass = "http://localhost:${toString config.services.prometheus.exporters.graphite.port}";
        "/".root = config.services.sitespeedio.outputDir;
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
