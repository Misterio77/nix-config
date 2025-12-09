{config, ...}: {
  services.firefly-iii = {
    enable = true;
    settings = {
      APP_KEY_FILE = config.sops.secrets.firefly-key.path;
      ENABLE_EXCHANGE_RATES = "true";
      ENABLE_EXTERNAL_RATES = "true";
    };
    enableNginx = true;
    virtualHost = "firefly.m7.rs";
  };

  services.nginx.virtualHosts.${config.services.firefly-iii.virtualHost} = {
    forceSSL = true;
    enableACME = true;
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
