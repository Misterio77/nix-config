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
      user = config.services.prowlarr.user;
      group = config.services.prowlarr.group;
      mode = "0700";
    }];
  };
}
