{config, ...}: {
  services.lidarr = {
    enable = true;
    settings = {
      server.port = 8686;
    };
  };

  environment.persistence = {
    "/persist".directories = [{
      directory = "/var/lib/lidarr";
      user = config.services.lidarr.user;
      group = config.services.lidarr.group;
    }];
  };
}
