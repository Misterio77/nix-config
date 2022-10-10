{ config, pkgs, lib, ... }:
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
    buildMachines =
      (lib.optional (config.networking.hostName != "atlas") {
        hostName = "atlas";
        maxJobs = 12;
        speedFactor = 100;
        sshKey = config.sops.secrets.builder-ssh-key.path;
        sshUser = config.users.users.builder.name;
        systems = [ "x86_64-linux" "aarch64-linux" ];
      }) ++
      (lib.optional (config.networking.hostName != "maia") {
        hostName = "maia";
        maxJobs = 8;
        speedFactor = 80;
        sshKey = config.sops.secrets.builder-ssh-key.path;
        sshUser = config.users.users.builder.name;
        systems = [ "x86_64-linux" "aarch64-linux" ];
      }) ++
      [{
        hostName = "local";
        protocol = null;
        systems = [ "builtin" ]
        ++ [ pkgs.system ]
        ++ config.boot.binfmt.emulatedSystems;
      }];
  };

  sops.secrets.builder-ssh-key = {
    sopsFile = ../secrets.yaml;
    owner = config.users.users.builder.name;
    group = config.users.users.builder.group;
    mode = "0440";
  };
}
