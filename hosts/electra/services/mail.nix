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
  };

  sops.secrets.gabriel-mail-password = {
    sopsFile = ../secrets.yaml;
  };
}
