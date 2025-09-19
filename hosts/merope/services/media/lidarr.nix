{config, ...}: {
  services.lidarr = {
    enable = true;
    settings = {
      server.port = 8686;
    };
  };

  # Add lidarr to deluge's and nzbget's groups
  # Make sure lidarr can hard-link their files
  users.users.lidarr.extraGroups = [
    config.users.users.deluge.group
    config.services.nzbget.group
  ];

  environment.persistence = {
    "/persist".directories = [{
      directory = "/var/lib/lidarr";
      user = config.services.lidarr.user;
      group = config.services.lidarr.group;
      mode = "0700";
    }];
  };
}
