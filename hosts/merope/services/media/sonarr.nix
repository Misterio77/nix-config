{config, ...}: {
  services.sonarr = {
    enable = true;
    settings = {
      server.port = 8687;
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
        directory = "/var/lib/sonarr";
        user = config.services.sonarr.user;
        group = config.services.sonarr.group;
        mode = "0700";
      }
      {
        directory = "/srv/media/tv";
        user = config.services.sonarr.user;
        group = config.services.sonarr.group;
        mode = "0755";
      }
    ];
  };
}
