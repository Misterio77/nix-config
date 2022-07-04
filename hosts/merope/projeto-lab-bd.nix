{ config, inputs, ... }: {
  imports = [ inputs.projeto-lab-bd.nixosModules.default ];

  services = {
    projeto-labbd = {
      enable = true;
      database = "postgresql:///labbd?user=labbd&host=/var/run/postgresql";
      environmentFile = config.sops.secrets.projeto-lab-bd.path;
      port = 8083;
    };

    postgresql = {
      ensureDatabases = [ "labbd" ];
      ensureUsers = [{
        name = "labbd";
        ensurePermissions = { "DATABASE labbd" = "ALL PRIVILEGES"; };
      }];
    };

    nginx.virtualHosts =
      let
        location = "http://localhost:${toString config.services.projeto-labbd.port}";
      in
      {
        "bd.misterio.me" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = location;
        };
      };
  };

  sops.secrets.projeto-lab-bd = {
    owner = "labbd";
    group = "labbd";
    sopsFile = ./secrets/keys.yaml;
  };
}
