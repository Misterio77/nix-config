{config, ...}: {
  services.immich = {
    enable = true;
    accelerationDevices = ["/dev/dri/renderD128"];
    mediaLocation = "/srv/media/photos";
    settings = {
      server.externalDomain = "https://photos.m7.rs";
    };
  };

  services.nginx.virtualHosts."photos.m7.rs" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.immich.port}";
      proxyWebsockets = true;
    };
  };

  /*
  No need for this if mediaLocation is in a non ephemeral mountpoint
  environment.persistence = {
    "/persist".directories = [
      {
        directory = config.services.immich.mediaLocation;
        user = config.services.immich.user;
        group = config.services.immich.group;
        mode = "0700";
      }
    ];
  };
  */

  systemd.tmpfiles.settings.srv-media-photos."/srv/media/photos".d = {
    user = config.services.immich.user;
    group = config.services.immich.group;
    mode = "0750";
  };
}
