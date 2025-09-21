{config, ...}: {
  services.recyclarr = {
    enable = true;
    configuration = {
      sonarr.main-sonarr = {
        api_key._secret = config.sops.secrets.sonarr-key.path;
        base_url = "http://localhost:${toString config.services.sonarr.settings.server.port}";
        delete_old_custom_formats = true;
        replace_existing_custom_formats = true;
        include = [
          # Use anime quality definition globally (i.e. prefer smaller sizes)
          { template = "sonarr-quality-definition-anime"; }
          # WEB-1080p
          { template = "sonarr-v4-quality-profile-web-1080p"; }
          { template = "sonarr-v4-custom-formats-web-1080p"; }
          # Remux-1080p - Anime
          { template = "sonarr-v4-quality-profile-anime"; }
          { template = "sonarr-v4-custom-formats-anime"; }
        ];
      };
      radarr.main-radarr = {
        api_key._secret = config.sops.secrets.radarr-key.path;
        base_url = "http://localhost:${toString config.services.radarr.settings.server.port}";
        delete_old_custom_formats = true;
        replace_existing_custom_formats = true;
        include = [
          # Use anime quality definition globally (i.e. prefer smaller sizes)
          { template = "radarr-quality-definition-anime"; }
          # Remux-1080p - Anime
          { template = "radarr-quality-profile-anime"; }
          { template = "radarr-custom-formats-anime"; }
          # HD Bluray + WEB
          { template = "radarr-quality-profile-hd-bluray-web"; }
          { template = "radarr-custom-formats-hd-bluray-web"; }
          # French, HD Bluray + WEB
          # (VF means "I want multiple (original+french), fallback to only french if multi is not available")
          { template = "radarr-quality-profile-hd-bluray-web-french-multi-vf"; }
          { template = "radarr-custom-formats-hd-remux-web-french-multi-vf"; }
        ];
      };
    };
  };

  sops.secrets = {
    sonarr-key = {
      sopsFile = ../../secrets.yaml;
      owner = config.services.recyclarr.user;
      group = config.services.recyclarr.group;
    };
    radarr-key = {
      sopsFile  = ../../secrets.yaml;
      owner = config.services.recyclarr.user;
      group = config.services.recyclarr.group;
    };
  };
}
