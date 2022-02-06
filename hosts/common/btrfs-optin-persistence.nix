{ lib, hostname, ... }:

{
  boot = {
    initrd = {
      postDeviceCommands = lib.mkBefore ''
        mkdir -p /mnt
        mount -o subvol=/ /dev/disk/by-label/${hostname} /mnt

        echo "Cleaning subvolume"
        btrfs subvolume list -o /mnt/root | cut -f9 -d ' ' |
        while read subvolume; do
          btrfs subvolume delete "/mnt/$subvolume"
        done && btrfs subvolume delete /mnt/root

        echo "Restoring blank subvolume"
        btrfs subvolume snapshot /mnt/root-blank /mnt/root

        umount /mnt
      '';
      supportedFilesystems = [ "btrfs" ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=zstd" ];
    };

    "/persist" = {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" ];
      neededForBoot = true;
    };

    "/dotfiles" = {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=dotfiles" "compress=zstd" ];
    };

    "/swap" = {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=swap" "noatime" "compress=lzo" ];
    };
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 4096;
  }];

}
