{ config, pkgs, lib, ... }:
let
  hostname = config.networking.hostName;
  sshKey = config.sops.secrets.builder-ssh-key.path;
  sshUser = config.users.users.builder.name;

  coreCount = {
    atlas = 12;
    maia = 8;
    merope = 4;
    pleione = 16;
    electra = 2;
  };
  speedFactor = {
    atlas = 100;
    maia = 60;
    pleione = 50;
    electra = 20;
    merope = 20;
  };
in
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
      (lib.optional ( hostname != "atlas") {
        hostName = "atlas";
        systems = [ "x86_64-linux" "aarch64-linux" ];

        inherit sshUser sshKey;
        maxJobs = coreCount.atlas;
        speedFactor = speedFactor.atlas;
      }) ++
      (lib.optional (hostname != "maia") {
        hostName = "maia";
        systems = [ "x86_64-linux" "aarch64-linux" ];

        inherit sshUser sshKey;
        maxJobs = coreCount.maia;
        speedFactor = speedFactor.maia;

      }) ++
      [{
        hostName = "localhost";
        systems = [ "builtin" pkgs.system ] ++ config.boot.binfmt.emulatedSystems;

        protocol = null;
        maxJobs = coreCount.${hostname};
        speedFactor = speedFactor.${hostname};
      }];
  };

  sops.secrets.builder-ssh-key = {
    sopsFile = ../secrets.yaml;
    owner = config.users.users.builder.name;
    group = config.users.users.builder.group;
    mode = "0440";
  };
}
