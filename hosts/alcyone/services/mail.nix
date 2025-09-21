{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.nixos-mailserver.nixosModules.mailserver];

  # https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/issues/275
  services.dovecot2.sieve.extensions = ["fileinto"];

  mailserver = rec {
    stateVersion = 3;
    enable = true;
    fqdn = "mail.m7.rs";
    sendingFqdn = "alcyone.m7.rs";
    domains = [
      "m7.rs"
      "misterio.me"
      "gsfontes.com"
    ];
    useFsLayout = true;
    certificateScheme = "acme-nginx";
    localDnsResolver = false;
    loginAccounts = {
      "hi@m7.rs" = {
        # mkpasswd -sm bcrypt
        hashedPasswordFile = config.sops.secrets.gabriel-mail-password.path;
        aliases = map (d: "@" + d) domains;
      };
      "grafana@m7.rs" = lib.mkIf config.services.grafana.enable {
        sendOnly = true;
        hashedPasswordFile = config.sops.secrets.grafana-mail-password-hashed.path;
      };
    };
    mailboxes = {
      Archive = {
        auto = "subscribe";
        specialUse = "Archive";
      };
      Drafts = {
        auto = "subscribe";
        specialUse = "Drafts";
      };
      Sent = {
        auto = "subscribe";
        specialUse = "Sent";
      };
      Junk = {
        auto = "subscribe";
        specialUse = "Junk";
      };
      Trash = {
        auto = "subscribe";
        specialUse = "Trash";
      };
    };
    mailDirectory = "/srv/mail/vmail";
    sieveDirectory = "/srv/mail/sieve";
    dkimKeyDirectory = "/srv/mail/dkim";
  };

  # Prefer ipv4 and use main ipv6 to avoid reverse DNS issues
  # CHANGEME when switching hosts
  services.postfix.settings.main = {
    smtp_bind_address6 = "2001:19f0:b800:1bf8::1";
    smtp_address_preference = "ipv4";
  };

  sops.secrets = {
    gabriel-mail-password.sopsFile = ../secrets.yaml;
    grafana-mail-password-hashed.sopsFile = ../secrets.yaml;
  };

  # Webmail
  services.roundcube = rec {
    enable = true;
    package = pkgs.roundcube.withPlugins (p: [p.carddav]);
    maxAttachmentSize = 200;
    hostName = "mail.m7.rs";
    extraConfig = ''
      $config['smtp_host'] = "tls://${hostName}:587";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      $config['plugins'] = [ "carddav" ];
    '';
  };

  # Autoconfig
  services.automx2 = {
    enable = true;
    domain = "m7.rs";
    settings = {
      provider = "Gabriel Fontes";
      domains = ["m7.rs" "misterio.me" "gsfontes.com"];
      servers = [
        { type = "imap"; name = "mail.m7.rs"; }
        { type = "smtp"; name = "mail.m7.rs"; }
      ];
    };
  };
  services.nginx.virtualHosts = let
    redir = to: {
      forceSSL = true;
      enableACME = true;
      locations."/".return = "302 https://${to}$request_uri";
    };
  in {
    "autoconfig.misterio.me" = redir "autoconfig.m7.rs";
    "autoconfig.gsfontes.com" = redir "autoconfig.m7.rs";
    "autodiscover.misterio.me" = redir "autodiscover.m7.rs";
    "autodiscover.gsfontes.com" = redir "autodiscover.m7.rs";
  };

  environment.persistence = {
    "/persist".directories = [
      {
        directory = "/var/lib/rspamd";
        user = "rspamd";
        group = "rspamd";
        mode = "0700";
      }
    ];
  };

  systemd.tmpfiles.settings.srv-mail."/srv/mail".d = {
    mode = "755"; # The inner dirs have more strict permissions, set by their homeMode
  };
}
