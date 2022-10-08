{ hostname, config, ... }:
{
  users = {
    users.builder = {
      isSystemUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz0dIbaTuAihil/si33MQSFH5yBFoupwnV5gcq2CCbO (none)"
      ];
      group = "builder";
    };
    groups.builder = { };
  };

  nix = {
    settings.trusted-users = [ config.users.users.builder.user ];
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "atlas";
        maxJobs = 12;
        speedFactor = 100;
        sshKey = config.sops.secrets.builder-ssh-key.path;
        sshUser = config.users.users.builder.user;
        systems = [ "x86_64-linux" "aarch64-linux" ];
      }
      {
        hostName = "maia";
        maxJobs = 8;
        speedFactor = 50;
        sshKey = config.sops.secrets.builder-ssh-key.path;
        sshUser = config.users.users.builder.user;
        systems = [ "x86_64-linux" "aarch64-linux" ];
      }
    ];
  };

  sops.secrets.builder-ssh-key = {
    sopsFile = ../secrets.yaml;
  };
}
