{config, ...}: {
  services.firefly-iii = {
    enable = true;
    settings = {
      APP_KEY_FILE = config.sops.secrets.firefly-key.path;
      ENABLE_EXCHANGE_RATES = "true";
      ENABLE_EXTERNAL_RATES = "true";
      SITE_OWNER = "hi@m7.rs";
      MAIL_MAILER = "smtp";
      MAIL_FROM = "firefly@m7.rs";
      MAIL_HOST = "mail.m7.rs";
      MAIL_PORT = 465;
      MAIL_ENCRYPTION = "tls";
      MAIL_USERNAME = "firefly@m7.rs";
      MAIL_PASSWORD = config.sops.secrets.firefly-mail-password.path;
    };
    enableNginx = true;
    virtualHost = "firefly.m7.rs";
  };

  services.nginx.virtualHosts.${config.services.firefly-iii.virtualHost} = {
    forceSSL = true;
    enableACME = true;
  };

  sops.secrets = {
    firefly-key = {
      owner = "firefly-iii";
      group = "nginx";
      sopsFile = ../secrets.yaml;
    };
    firefly-mail-password = {
      owner = "firefly-iii";
      group = "nginx";
      sopsFile = ../secrets.yaml;
    };
  };

  environment.persistence = {
    "/persist".directories = ["/var/lib/firefly-iii"];
  };
}
