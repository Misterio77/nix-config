{config, ...}: {
  services.prowlarr = {
    enable = true;
    settings = {
      server.port = 8685;
    };
  };

  environment.persistence = {
    "/persist".directories = [{
      directory = config.services.prowlarr.dataDir;
      user = "prowlarr";
      group = "prowlarr";
      mode = "0700";
    }];
  };
}
