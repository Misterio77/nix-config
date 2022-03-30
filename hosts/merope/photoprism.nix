{ lib, config, persistence, ... }:
{
  services = {
    photoprism = {
      enable = true;
      originalsDir = "/media/photos";
    };

    nginx.virtualHosts =
      let
        location = "http://localhost:${toString config.services.photoprism.port}";
      in
      {
        "photos.misterio.me" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = location;
            proxyWebsockets = true;
          };
        };
      };
  };

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [ "/var/lib/photoprism" ];
  };
}
