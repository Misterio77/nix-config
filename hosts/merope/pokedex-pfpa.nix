{ config, inputs, ... }: {
  imports = [ inputs.pokedex-pfpa.nixosModule ];

  services = {
    pokedex-pfpa = {
      enable = true;
      port = 8083;
      sessionKeyFile = /srv/pokedex.key;
    };

    postgresql = {
      ensureDatabases = [ "pokedex" ];
      ensureUsers = [{
        name = "pokedex";
        ensurePermissions = { "DATABASE pokedex" = "ALL PRIVILEGES"; };
      }];
    };

    nginx.virtualHosts = let
      location = "http://localhost:${toString config.services.pokedex-pfpa.port}";
    in {
      "pokedex.misterio.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = location;
      };
    };
  };
}
