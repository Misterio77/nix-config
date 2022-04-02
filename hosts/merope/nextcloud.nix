{ lib, config, persistence, ... }:
{
  services = {
    nextcloud = {
      enable = true;
      hostName = "nextcloud.misterio.me";
      nginx.enable = true;
      https = true;
      adminpassFile = "/srv/nextcloud.password";
    };

    nginx.virtualHosts =
      {
        "nextcloud.misterio.me" = {
          forceSSL = true;
          enableACME = true;
        };
      };
  };

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [ "/var/lib/nextcloud" ];
  };
}
