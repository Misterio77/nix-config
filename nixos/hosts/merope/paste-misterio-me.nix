{ config, inputs, ... }: {
  imports = [ inputs.paste-misterio-me.nixosModule ];

  services = {
    paste-misterio-me = {
      enable = true;
      database =
        "postgresql:///paste?user=paste&host=/var/run/postgresql";
      environmentFile = "/srv/paste-misterio-me.key";
      port = 8082;
    };

    postgresql = {
      ensureDatabases = [ "paste" ];
      ensureUsers = [{
        name = "paste";
        ensurePermissions = { "DATABASE paste" = "ALL PRIVILEGES"; };
      }];
    };

    nginx.virtualHosts = let
      location = "http://localhost:${toString config.services.paste-misterio-me.port}";
    in {
      "paste.misterio.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = location;
      };
    };
  };
}
