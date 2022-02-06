{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" ];
      luks.devices.${hostname}.device = "/dev/disk/by-label/${hostname}";
      postDeviceCommands = lib.mkBefore ''
        mkdir -p /mnt
        mount -o subvol=/ /dev/mapper/${hostname} /mnt

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
      device = "/dev/mapper/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" ];
    };

    "/nix" = {
      device = "/dev/mapper/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=zstd" ];
    };

    "/persist" = {
      device = "/dev/mapper/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" ];
      neededForBoot = true;
    };

    "/dotfiles" = {
      device = "/dev/mapper/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=dotfiles" "compress=zstd" ];
    };

    "/swap" = {
      device = "/dev/mapper/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=swap" "noatime" "compress=lzo" ];
    };

    "/boot" = {
      device = "/dev/mapper/${hostname}";
      fsType = "btrfs";
      options = [ "subvol=boot" "compress=zstd" ];
    };

    "/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };

    "/media" = {
      device = "/dev/disk/by-label/MEDIA_HDD";
      fsType = "ext4";
    };
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 4096;
  }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
