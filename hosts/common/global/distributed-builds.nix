{ hostname, config, pkgs, ... }:
{
  users = {
    users.builder = {
      isSystemUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz0dIbaTuAihil/si33MQSFH5yBFoupwnV5gcq2CCbO (none)"
      ];
      group = "builder";
      shell = pkgs.bash;
    };
    groups.builder = { };
  };

  nix = {
    settings.trusted-users = [ config.users.users.builder.name ];
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "atlas";
        maxJobs = 12;
        speedFactor = 100;
        sshKey = config.sops.secrets.builder-ssh-key.path;
        sshUser = config.users.users.builder.name;
        systems = [ "x86_64-linux" "aarch64-linux" ];
      }
      {
        hostName = "maia";
        maxJobs = 8;
        speedFactor = 80;
        sshKey = config.sops.secrets.builder-ssh-key.path;
        sshUser = config.users.users.builder.name;
        systems = [ "x86_64-linux" "aarch64-linux" ];
      }
      {
        hostName = "pleione";
        maxJobs = 16;
        speedFactor = 40;
        sshKey = config.sops.secrets.builder-ssh-key.path;
        sshUser = config.users.users.builder.name;
        systems = [ "x86_64-linux" "aarch64-linux" ];
      }
      {
        hostName = "merope";
        maxJobs = 4;
        speedFactor = 10;
        sshKey = config.sops.secrets.builder-ssh-key.path;
        sshUser = config.users.users.builder.name;
        systems = [ "aarch64-linux" ];
      }
      {
        hostName = "electra";
        maxJobs = 1;
        speedFactor = 10;
        sshKey = config.sops.secrets.builder-ssh-key.path;
        sshUser = config.users.users.builder.name;
        systems = [ "x86_64-linux" ];
      }
    ];
  };

  sops.secrets.builder-ssh-key = {
    sopsFile = ../secrets.yaml;
    owner = config.users.users.builder.name;
    group = config.users.users.builder.group;
    mode = "0440";
  };
}
