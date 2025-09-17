{config, ...}: {
  services.lidarr = {
    enable = true;
  };

  environment.persistence = {
    "/persist".directories = [{
      directory = "/var/lib/lidarr";
      user = config.services.user;
      group = config.services.group;
    }];
  };
}
