{config, lib, pkgs, ...}: {
  systemd.services.jellysearch = {
    description = "Jellysearch search proxy";
    script = lib.getExe pkgs.jellysearch;
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      JELLYFIN_URL = "http://localhost:${toString config.services.jellyfin.port}";
      JELLYFIN_CONFIG_DIR = config.services.jellyfin.configDir;
      MEILI_URL = "http://localhost:${toString config.services.meilisearch.listenPort}";
      INDEX_CRON = "0 0 * * * ?"; # hourly
    };
    serviceConfig = {
      User = "jellysearch";
      Group = "jellysearch";
    };
  };

  users = {
    users.jellysearch = {
      home = "/var/lib/jellysearch";
      group = "jellysearch";
      isSystemUser = true;
      # Add jellysearch to jellyfin group so that it can read config files
      extraGroups = [config.services.jellyfin.group];
    };
    groups.jellysearch = {};
  };

  services.meilisearch = {
    enable = true;
  };
}
