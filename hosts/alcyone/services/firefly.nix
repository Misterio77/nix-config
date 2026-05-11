{config, pkgs, ...}: {
  services.firefly-iii = {
    enable = true;
    package = pkgs.firefly-iii.overrideAttrs (old: rec {
      pname = "firefly-iii";
      version = "6.4.22";
      src = pkgs.fetchFromGitHub {
        owner = "firefly-iii";
        repo = "firefly-iii";
        tag = "v${version}";
        hash = "sha256-i20D0/z6GA7pZYrWvRJ8tUlptNI5Cl/e9UY0hKg9SP8=";
      };
      composerVendor = pkgs.php.mkComposerVendor {
        inherit pname src version;
        composerStrictValidation = true;
        strictDeps = true;
        vendorHash = "sha256-m+esW/yQs/GSwnw2iqVfSMXCf6/5M4634GUbt4Nnvbg=";
      };
      npmDeps = pkgs.fetchNpmDeps {
        inherit src;
        name = "${pname}-npm-deps";
        hash = "sha256-pu8dxL0NRB1cyqlQEf2zT2wdVp2fbe+Vp85qMs7f6s0=";
      };
    });
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
