{ config, inputs, ... }:
{
  imports = [
    inputs.nixos-mailserver.nixosModules.mailserver
  ];

  mailserver = {
    enable = true;
    fqdn = "mail.m7.rs";
    sendingFqdn = "electra.m7.rs";
    domains = [ "m7.rs" ];
    useFsLayout = true;
    certificateScheme = 3;
    localDnsResolver = false;
    loginAccounts = {
      "hi@m7.rs" = {
        hashedPasswordFile = config.sops.secrets.gabriel-mail-password.path;
        aliases = [ "@m7.rs" ];
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

  sops.secrets = {
    gabriel-mail-password = {
      sopsFile = ../secrets.yaml;
    };
    smtp-relay-creds = {
      sopsFile = ../secrets.yaml;
    };
  };

  # Relay server while vultr does not unblock smtp
  # https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/issues/148
  services.postfix.extraConfig = ''
    smtp_sasl_auth_enable = yes
    smtp_sasl_password_maps = hash:${config.sops.secrets.smtp-relay-creds.path}
    smtp_sasl_security_options = noanonymous
    smtp_sasl_mechanism_filter = AUTH LOGIN
    relayhost = smtp.fastmail.com:587
  '';
}
