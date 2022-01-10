{ config, ... }: {
  services = {
    paste-misterio-me = {
      enable = true;
      database =
        "postgresql:///paste-misterio-me?user=paste-misterio-me&host=/var/run/postgresql";
      openFirewall = true;
      port = 8082;
    };

    postgresql = {
      ensureDatabases = [ "paste-misterio-me" ];
      ensureUsers = [{
        name = "paste-misterio-me";
        ensurePermissions = { "DATABASE paste-misterio-me" = "ALL PRIVILEGES"; };
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

    avahi.subdomains = [ "paste" ];
  };
}
