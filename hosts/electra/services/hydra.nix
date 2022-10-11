{ config, pkgs, ... }: {
  nix = {
    settings.trusted-users = [ config.users.users.builder.name ];
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "atlas";
        systems = [ "x86_64-linux" "aarch64-linux" ];

        sshKey = config.sops.secrets.builder-ssh-key.path;
        sshUser = config.users.users.builder.name;
        maxJobs = 12;
        speedFactor = 100;
      }
      {
        hostName = "maia";
        systems = [ "x86_64-linux" "aarch64-linux" ];

        sshKey = config.sops.secrets.builder-ssh-key.path;
        sshUser = config.users.users.builder.name;
        maxJobs = 8;
        speedFactor = 60;
      }
      {
        hostName = "local";
        systems = [ "builtin" "x86_64-linux" "aarch64-linux" ];
        protocol = null;

        maxJobs = 2;
        speedFactor = 20;
      }
    ];

    # https://github.com/NixOS/nix/issues/5039
    extraOptions = ''
      allowed-uris = https:// http://
    '';
  };

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
          jobs = .*
          useShortContext = true
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

  users = {
    groups = {
      builder = { };
    };
    users = {
      builder = {
        isSystemUser = true;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz0dIbaTuAihil/si33MQSFH5yBFoupwnV5gcq2CCbO (none)" ];
        group = "builder";
        shell = pkgs.bash;
      };
      hydra-queue-runner.extraGroups = with config.users.users; [ hydra.group builder.group ];
      hydra-www.extraGroups = with config.users.users; [ hydra.group builder.group ];
    };
  };

  sops.secrets = {
    hydra-gh-auth = {
      sopsFile = ../secrets.yaml;
      owner = config.users.users.hydra.name;
      group = config.users.users.hydra.group;
      mode = "0440";
    };
    builder-ssh-key = {
      sopsFile = ../secrets.yaml;
      owner = config.users.users.builder.name;
      group = config.users.users.builder.group;
      mode = "0440";
    };
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/hydra" ];
  };
}
