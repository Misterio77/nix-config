{
  config,
  ...
}: {
  services = {
    navidrome = {
      enable = true;
      settings = {
        Address = "0.0.0.0";
        Port = 4533;
        MusicFolder = "/srv/music";
        CovertArtPriority = "*.jpg, *.JPG, *.png, *.PNG, embedded";
        AutoImportPlaylists = false;
        EnableSharing = true;
        "LastFM.Enabled" = true;
        "LastFM.ApiKey" = config.sops.secrets.last-fm-key.path;
        "LastFM.Secret" = config.sops.secrets.last-fm-secret.path;
      };
    };

    nginx.virtualHosts = {
      "music.m7.rs" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString config.services.navidrome.settings.Port}";
      };
      "music.misterio.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/".return = "302 https://music.m7.rs$request_uri";
      };
    };
  };

  sops.secrets = {
    last-fm-key = {
      sopsFile = ../secrets.yaml;
      owner = config.users.users.navidrome.name;
      group = config.users.users.navidrome.name;
    };
    last-fm-secret = {
      sopsFile = ../secrets.yaml;
      owner = config.users.users.navidrome.name;
      group = config.users.users.navidrome.name;
    };
  };

  environment.persistence = {
    "/persist".directories = ["/var/lib/navidrome"];
  };
}
