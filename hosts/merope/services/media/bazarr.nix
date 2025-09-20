{config, ...}: {
  services.sonarr = {
    enable = true;
    settings = {
      server.port = 8689;
    };
  };

  # Add bazarr to sonarr and radarr's groups
  users.users.sonarr.extraGroups = [
    config.services.sonarr.group
    config.services.radarr.group
  ];
}
