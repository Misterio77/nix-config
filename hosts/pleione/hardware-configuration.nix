{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules =
        [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
      luks.devices."pleione".device = "/dev/disk/by-label/Pleione";
    };
    kernelModules = [ "kvm-amd" ];
    supportedFilesystems = [ "btrfs" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/pleione";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" ];
    };

    "/nix" = {
      device = "/dev/mapper/pleione";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=zstd" ];
    };

    "/persist" = {
      device = "/dev/mapper/pleione";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" ];
      neededForBoot = true;
    };

    "/swap" = {
      device = "/dev/mapper/pleione";
      fsType = "btrfs";
      options = [ "subvol=swap" "noatime" "compress=lzo" ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 4096;
  }];

  powerManagement.cpuFreqGovernor = "powersave";

}
