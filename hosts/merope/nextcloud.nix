{ config, pkgs, ... }:
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
      config.adminpassFile = config.sops.secrets.nextcloud-password.path;
    };

    nginx.virtualHosts.${hostName} = {
      forceSSL = true;
      enableACME = true;
    };
  };

  sops.secrets.nextcloud-password = {
    owner = "nextcloud";
    group = "nextcloud";
    sopsFile = ./secrets.yaml;
  };
}
