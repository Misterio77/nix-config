{config, ...}: {
  services.bazarr = {
    enable = true;
    listenPort = 8689;
  };

  # Add bazarr to sonarr and radarr's groups
  users.users.bazarr.extraGroups = [
    config.services.sonarr.group
    config.services.radarr.group
  ];
}
