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
    config.services.sabnzbd.group
  ];

  environment.persistence = {
    "/persist".directories = [
      {
        directory = config.services.lidarr.dataDir;
        user = config.services.lidarr.user;
        group = config.services.lidarr.group;
        mode = "0700";
      }
    ];
  };

  systemd.tmpfiles.srv-media-music.settings."/srv/media/music".d = {
    user = config.services.lidarr.user;
    group = config.services.lidarr.group;
    mode = "0755";
  };
}
