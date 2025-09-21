{config, ...}: {
  services.radarr = {
    enable = true;
    settings = {
      server.port = 8687;
    };
  };

  # Add radarr to deluge's and nzbget's groups
  # Make sure radarr can hard-link their files
  users.users.radarr.extraGroups = [
    config.users.users.deluge.group
    config.services.sabnzbd.group
  ];

  environment.persistence = {
    "/persist".directories = [
      {
        directory = config.services.radarr.dataDir;
        user = config.services.radarr.user;
        group = config.services.radarr.group;
        mode = "0700";
      }
    ];
  };

  systemd.tmpfiles.settings.srv-media-movies."/srv/media/movies".d = {
    user = config.services.radarr.user;
    group = config.services.radarr.group;
    mode = "0755";
  };
}
