{config, ...}: {
  services.firefly-iii = {
    enable = true;
    settings = {
      APP_KEY_FILE = config.sops.secrets.firefly-key.path;
      DB_CONNECTION = "mysql";
      DB_DATABASE = "firefly";
      DB_HOST = "localhost";
      DB_USERNAME = "firefly-iii";
    };
    enableNginx = true;
    virtualHost = "firefly.m7.rs";
  };

  services.mysql = let
    inherit (config.services.firefly-iii) settings;
  in {
    ensureDatabases = [settings.DB_DATABASE];
    ensureUsers = [
      {
        name = settings.DB_USERNAME;
        ensurePermissions = {"${settings.DB_DATABASE}.*" = "ALL PRIVILEGES";};
      }
    ];
  };

  sops.secrets.firefly-key = {
    owner = "firefly-iii";
    group = "nginx";
    sopsFile = ../secrets.yaml;
  };

  environment.persistence = {
    "/persist".directories = ["/var/lib/firefly-iii"];
  };
}
