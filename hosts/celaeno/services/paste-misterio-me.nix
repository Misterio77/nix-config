{ config, inputs, pkgs, ... }: {
  imports = [
    inputs.paste-misterio-me.nixosModules.server
  ];

  services = {
    paste-misterio-me = {
      enable = true;
      package = inputs.paste-misterio-me.packages.${pkgs.system}.server;
      database = "postgresql:///paste?user=paste&host=/var/run/postgresql";
      environmentFile = config.sops.secrets.paste-misterio-me-secrets.path;
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

  sops.secrets.paste-misterio-me-secrets = {
    owner = "paste";
    group = "paste";
    sopsFile = ../secrets.yaml;
  };
}
