{
  services = {
    projeto-bd = {
      enable = true;
      database = "postgresql:///root?user=projetobd&host=/var/run/postgresql";
      openFirewall = true;
      tlsChain = "/var/lib/acme/bd.misterio.me/fullchain.pem";
      tlsKey = "/var/lib/acme/bd.misterio.me/key.pem";
    };

    postgresql = {
      enable = true;
      ensureDatabases = [ "projetobd" ];
      ensureUsers = [
        {
          name = "projetobd";
          ensurePermissions = {
            "DATABASE projetobd" = "ALL PRIVILEGES";
          };
        }
      ];
    };
  };
  environment.persistence."/data" = {
    directories = [
      "/var/lib/postgresql"
    ];
  };
}
