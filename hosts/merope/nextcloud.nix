{ lib, pkgs, persistence, ... }:
{
  services = {
    nextcloud = {
      package = pkgs.nextcloud23;
      enable = true;
      hostName = "nextcloud.misterio.me";
      https = true;
      config.adminpassFile = "/srv/nextcloud.password";
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
