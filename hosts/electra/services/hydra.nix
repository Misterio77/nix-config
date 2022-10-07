{ config, ... }:
{
  services = {
    hydra = {
      enable = true;
      hydraURL = "https://hydra.m7.rs";
      notificationSender = "hydra@m7.rs";
      listenHost = "localhost";
      smtpHost = "localhost";
      useSubstitutes = true;
      extraConfig = /* xml */ ''
        Include ${config.sops.secrets.hydra-gh-auth.path}
        <githubstatus>
          jobs = nix-config:master:*
        </githubstatus>
      '';
    };
    nginx.virtualHosts = {
      "hydra.m7.rs" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass =
          "http://localhost:${toString config.services.hydra.port}";
      };
    };
  };
  users.users = let
    hydraGroup = config.users.users.hydra.group;
  in {
    hydra-queue-runner.extraGroups = [ hydraGroup ];
    hydra-www.extraGroups = [ hydraGroup ];
  };
  sops.secrets = {
    hydra-gh-auth = {
      sopsFile = ../secrets.yaml;
      owner = config.users.users.hydra.name;
      group = config.users.users.hydra.group;
      mode = "0440";
    };
  };
}
