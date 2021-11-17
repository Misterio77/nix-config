{
  services = {
    projeto-bd = {
      enable = true;
      database = "postgresql:///root?user=projeto-bd&host=/var/run/postgresql";
      openFirewall = true;
      tlsChain = "/var/lib/acme/bd.misterio.me/chain.pem";
      tlsKey = "/var/lib/acme/bd.misterio.me/key.pem";
    };

    postgresql = {
      enable = true;
      ensureDatabases = [ "projeto-bd" ];
      ensureUsers = [
        {
          name = "projeto-bd";
          ensurePermissions = {
            "DATABASE projeto-db" = "ALL PRIVILEGES";
          };
        }
      ];
    };
  };
}
