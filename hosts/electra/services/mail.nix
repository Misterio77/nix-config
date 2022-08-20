{ config, inputs, ... }:
{
  imports = [
    inputs.nixos-mailserver.nixosModules.mailserver
  ];

  mailserver = {
    enable = true;
    fqdn = "mail.fontes.dev.br";
    sendingFqdn = "electra.fontes.dev.br";
    domains = [ "fontes.dev.br" ];
    useFsLayout = true;
    certificateScheme = 3;
    localDnsResolver = false;
    loginAccounts = {
      "gabriel@fontes.dev.br" = {
        hashedPasswordFile = config.sops.secrets.gabriel-mail-password.path;
        aliases = [ "@fontes.dev.br" ];
      };
    };
  };

  sops.secrets.gabriel-mail-password = {
    sopsFile = ../secrets.yaml;
  };
}
