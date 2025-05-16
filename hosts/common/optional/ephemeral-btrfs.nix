# This file contains an ephemeral btrfs root configuration
# TODO: perhaps partition using disko in the future
# TODO: set the device through a custom option, or extract from config.disko.devices.disk.<name>.content.partitions.<name>.device
{
  lib,
  config,
  ...
}: let
  hostname = config.networking.hostName;
  wipeScript = ''
    mkdir /tmp -p
    MNTPOINT=$(mktemp -d)
    (
      mount -t btrfs -o subvol=/ /dev/disk/by-label/${hostname} "$MNTPOINT"
      trap 'umount "$MNTPOINT"' EXIT

      echo "Creating needed directories"
      mkdir -p "$MNTPOINT"/persist/var/{log,lib/{nixos,systemd}}
      if [ -e "$MNTPOINT/persist/dont-wipe" ]; then
        echo "Skipping wipe"
      else
        echo "Cleaning root subvolume"
        btrfs subvolume delete -R "$MNTPOINT/root"
        echo "Restoring blank subvolume"
        btrfs subvolume snapshot "$MNTPOINT/root-blank" "$MNTPOINT/root"
      fi
    )
  '';
  phase1Systemd = config.boot.initrd.systemd.enable;
in {
  boot.initrd = {
    supportedFilesystems = ["btrfs"];
    postDeviceCommands = lib.mkIf (!phase1Systemd) (lib.mkBefore wipeScript);
    systemd.services.restore-root = lib.mkIf phase1Systemd {
      description = "Rollback btrfs rootfs";
      wantedBy = ["initrd.target"];
      requires = ["dev-disk-by\\x2dlabel-${hostname}.device"];
      after = [
        "dev-disk-by\\x2dlabel-${hostname}.device"
        "systemd-cryptsetup@${hostname}.service"
      ];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = wipeScript;
    };
  };

  fileSystems = {
    "/" = lib.mkDefault {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [
        "subvol=root"
        "compress=zstd"
      ];
    };

    "/nix" = lib.mkDefault {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "noatime"
        "compress=zstd"
      ];
    };

    "/persist" = lib.mkDefault {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [
        "subvol=persist"
        "compress=zstd"
      ];
      neededForBoot = true;
    };

    "/swap" = lib.mkDefault {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [
        "subvol=swap"
        "noatime"
      ];
    };
  };
}
