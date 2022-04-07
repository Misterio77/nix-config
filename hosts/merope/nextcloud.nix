{ lib, pkgs, persistence, ... }:
let
  hostName = "nextcloud.misterio.me";
in {
  services = {
    nextcloud = {
      inherit hostName;
      package = pkgs.nextcloud23;
      enable = true;
      https = true;
      config.adminpassFile = "/srv/nextcloud.password";
    };

    nginx.virtualHosts.${hostName} = {
      forceSSL = true;
      enableACME = true;
    };
  };

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [ "/var/lib/nextcloud" ];
  };
}
