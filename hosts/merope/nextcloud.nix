{ pkgs, ... }:
let
  hostName = "nextcloud.misterio.me";
in
{
  services = {
    nextcloud = {
      inherit hostName;
      package = pkgs.nextcloud24;
      enable = true;
      https = true;
      home = "/media/nextcloud";
      config.adminpassFile = "/srv/nextcloud.password";
    };

    nginx.virtualHosts.${hostName} = {
      forceSSL = true;
      enableACME = true;
    };
  };
}
