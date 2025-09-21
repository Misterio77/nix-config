{config, ...}: {
  services.sonarr = {
    enable = true;
    settings = {
      server.port = 8688;
    };
  };

  # Add sonarr to deluge's and nzbget's groups
  # Make sure sonarr can hard-link their files
  users.users.sonarr.extraGroups = [
    config.users.users.deluge.group
    config.services.sabnzbd.group
  ];

  environment.persistence = {
    "/persist".directories = [
      {
        directory = config.services.sonarr.dataDir;
        user = config.services.sonarr.user;
        group = config.services.sonarr.group;
        mode = "0700";
      }
    ];
  };

  systemd.tmpfiles.srv-media-tv.settings."/srv/media/tv".d = {
    user = config.services.sonarr.user;
    group = config.services.sonarr.group;
    mode = "0755";
  };
}
