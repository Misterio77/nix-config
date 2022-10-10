{ config, inputs, pkgs, ... }:
let
  package = inputs.paste-misterio-me.packages.${pkgs.system}.paste-misterio-me;
  module =  inputs.paste-misterio-me.nixosModules.paste-misterio-me;
in {
  imports = [ module ];

  services = {
    paste-misterio-me = {
      inherit package;
      enable = true;
      database = "postgresql:///paste?user=paste&host=/var/run/postgresql";
      environmentFile = config.sops.secrets.paste-misterio-me-key.path;
      port = 8082;
    };

    postgresql = {
      ensureDatabases = [ "paste" ];
      ensureUsers = [{
        name = "paste";
        ensurePermissions = { "DATABASE paste" = "ALL PRIVILEGES"; };
      }];
    };

    nginx.virtualHosts."paste.misterio.me" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass =
        "http://localhost:${toString config.services.paste-misterio-me.port}";
    };
  };

  sops.secrets.paste-misterio-me-key = {
    owner = "paste";
    group = "paste";
    sopsFile = ../secrets.yaml;
  };
}
