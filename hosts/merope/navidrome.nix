{ lib, config, persistence, ... }: {
  services = {
    navidrome = {
      enable = true;
      settings = {
        Address = "0.0.0.0";
        Port = 4533;
        MusicFolder = "/media/music";
        CovertArtPriority = "*.jpg, *.JPG, *.png, *.PNG, embedded";
        AutoImportPlaylists = false;
      };
    };

    nginx.virtualHosts =
      let
        location = "http://localhost:${toString config.services.navidrome.settings.Port}";
      in
      {
        "music.misterio.me" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = location;
        };
      };
  };

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [ "/var/lib/private/navidrome" ];
  };
}
