{ config, ... }:
{
  services = {
    projeto-bd = {
      enable = true;
      database = "postgresql:///projetobd?user=projetobd&host=/var/run/postgresql";
      openFirewall = true;
      port = 8081;
    };

    postgresql = {
      ensureDatabases = [ "projetobd" ];
      ensureUsers = [{
        name = "projetobd";
        ensurePermissions = {
          "DATABASE projetobd" = "ALL PRIVILEGES";
        };
      }];
    };

    nginx.virtualHosts =
      let
        location = "http://localhost:${toString config.services.projeto-bd.port}";
      in
      {
        "bd.misterio.me" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = location;
        };

        "bd.merope.local" = {
          rejectSSL = true;
          locations."/".proxyPass = location;
        };
      };

    avahi.subdomains = [ "bd" ];
  };
}
