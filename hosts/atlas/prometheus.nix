{ ... }: {
  services.prometheus = {
    enable = true;
    scrapeConfigs = [{
      job_name = "teste";
      metrics_path = "/metrics";
      static_configs = [{
        targets = [ "localhost:8000" ];
      }];
    }];
  };
}
