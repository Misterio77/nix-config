{config, ...}: {
  services.lidarr = {
    enable = true;
    settings = {
      server.port = 8686;
    };
  };

  # Add lidarr to deluge's group
  # Make sure lidarr can hard-link deluge-owned files
  users.users.lidarr.extraGroups = [config.users.users.deluge.group];

  environment.persistence = {
    "/persist".directories = [{
      directory = "/var/lib/lidarr";
      user = config.services.lidarr.user;
      group = config.services.lidarr.group;
      mode = "0700";
    }];
  };
}
