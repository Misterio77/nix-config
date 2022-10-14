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
    atlas = 170;
    maia = 140;
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
      (lib.optional (hostname != "atlas") {
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
        systems = [ pkgs.system ] ++ config.boot.binfmt.emulatedSystems;

        inherit sshUser sshKey;
        maxJobs = coreCount.${hostname};
        # Give a little more priority to local builds
        speedFactor = speedFactor.${hostname} + 100;
      }];
  };

  # Script that makes sure /etc/nix/machines are only available ones
  systemd = {
    timers.builder-pinger = {
      description = "Build machine pinger timer";
      partOf = [ "builder-pinger.service" ];
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnBootSec = "0";
        OnUnitActiveSec = "5s";
      };
    };
    services.builder-pinger = {
      description = "Build machine pinger";
      enable = true;
      wantedBy = [ "multi-user.target" "post-resume.target" ];
      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
      };
      path = [ config.nix.package config.programs.ssh.package ];
      script = /* bash */ ''
        #!/usr/bin/env bash
        check_host() {
          line="$1"
          host="$(echo "$line" | cut -d ' ' -f1)"
          key="$(echo "$line" | cut -d ' ' -f3)"

          if [ "$key" == "-" ]; then
              args=""
          else
              args="ssh-key=$key"
          fi

          if timeout 2 nix store ping  --store "$host?$args"; then
              echo "$line" >> /etc/nix/machines-online
          fi
        }

        rm /etc/nix/machines-online -f 2> /dev/null
        touch /etc/nix/machines-online

        while read -r host_line; do
          check_host "$host_line" &
        done < "${config.environment.etc."nix/machines".source}"

        wait

        if ! diff /etc/nix/machines-online /etc/nix/machines; then
          systemctl is-active hydra-queue-runner -q && \
          systemctl restart hydra-queue-runner
        fi

        mv /etc/nix/machines-online /etc/nix/machines
      '';
    };
  };

  sops.secrets.builder-ssh-key = {
    sopsFile = ../secrets.yaml;
    owner = config.users.users.builder.name;
    group = config.users.users.builder.group;
    mode = "0440";
  };
}
