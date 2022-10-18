{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.nixos-mailserver.nixosModules.mailserver
  ];

  mailserver = rec {
    enable = true;
    fqdn = "mail.m7.rs";
    sendingFqdn = "electra.m7.rs";
    domains = [
      "m7.rs"
      "fontes.dev.br"
      "misterio.me"
      "gsfontes.com"
    ];
    useFsLayout = true;
    certificateScheme = 3;
    localDnsResolver = false;
    loginAccounts = {
      "hi@m7.rs" = {
        hashedPasswordFile = config.sops.secrets.gabriel-mail-password.path;
        aliases = map (d: "@" + d) domains;
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
    # When setting up check that /srv is persisted!
    mailDirectory = "/srv/mail/vmail";
    sieveDirectory = "/srv/mail/sieve";
    dkimKeyDirectory = "/srv/mail/dkim";
  };

  # Prefer ipv4 and use main ipv6 to avoid reverse DNS issues
  # CHANGEME when switching hosts
  services.postfix.extraConfig = ''
    smtp_bind_address6 = 2001:19f0:b800:1d54:5400:04ff:fe2a:c074
    smtp_address_preference = ipv4
  '';

  sops.secrets = {
    gabriel-mail-password = {
      sopsFile = ../secrets.yaml;
    };
  };

  # Webmail
  services.roundcube = rec {
    enable = true;
    package = pkgs.roundcube.withPlugins (p: [ p.carddav ]);
    hostName = "mail.m7.rs";
    extraConfig = ''
      $config['smtp_server'] = "tls://${hostName}";
      $config['smtp_user'] = "%u";
      $config['smtp_user'] = "%p";
      $config['plugins'] = [ "carddav" ];
    '';
  };
}
