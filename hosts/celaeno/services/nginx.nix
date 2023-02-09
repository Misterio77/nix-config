{ lib, ... }:
{
  services = {
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      clientMaxBodySize = "300m";
    };

    uwsgi = {
      enable = true;
      user = "nginx";
      group = "nginx";
      plugins = [ "cgi" ];
      instance = {
        type = "emperor";
        vassals = lib.mkBefore { };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
