{config, ...}: {
  services.firefly-iii = {
    enable = true;
    settings = {
      APP_KEY_FILE = config.sops.secrets.firefly-key.path;
    };
    enableNginx = true;
    virtualHost = "firefly.m7.rs";
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
