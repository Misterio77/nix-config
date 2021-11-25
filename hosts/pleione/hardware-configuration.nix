{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
      luks.devices."pleione".device = "/dev/disk/by-label/Pleione";
    };
    kernelModules = [ "kvm-amd" ];
    supportedFilesystems = [ "btrfs" ];
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=4G" "mode=755" ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    "/data/etc" = {
      device = "/dev/mapper/pleione";
      fsType = "btrfs";
      options = [ "subvol=data/etc" "compress=zstd" ];
    };

    "/data/games" = {
      device = "/dev/mapper/pleione";
      fsType = "btrfs";
      options = [ "subvol=data/games" "compress=zstd" ];
    };

    "/data/home" = {
      device = "/dev/mapper/pleione";
      fsType = "btrfs";
      options = [ "subvol=data/home" "compress=zstd" ];
      neededForBoot = true;
    };

    "/data/srv" = {
      device = "/dev/mapper/pleione";
      fsType = "btrfs";
      options = [ "subvol=data/srv" "compress=zstd" ];
    };

    "/data/var" = {
      device = "/dev/mapper/pleione";
      fsType = "btrfs";
      options = [ "subvol=data/var" "compress=zstd" ];
      neededForBoot = true;
    };

    "/dotfiles" = {
      device = "/dev/mapper/pleione";
      fsType = "btrfs";
      options = [ "subvol=dotfiles" "compress=zstd" ];
    };

    "/nix" = {
      device = "/dev/mapper/pleione";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=zstd" ];
    };
  };
  powerManagement.cpuFreqGovernor = "powersave";

}
