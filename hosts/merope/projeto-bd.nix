{
  services = {
    projeto-bd = {
      enable = true;
      database = "postgresql:///projetobd?user=root&host=/var/run/postgresql";
      openFirewall = true;
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

    nginx.virtualHosts = {
      "bd.misterio.me" = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };
}
