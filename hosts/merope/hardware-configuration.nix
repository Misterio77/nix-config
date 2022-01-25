{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" ];

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=4G" "mode=755" ];
    };

    "/data" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      neededForBoot = true;
    };

    "/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };

    "/mnt/media" = {
      device = "/dev/disk/by-label/MEDIA_HDD";
      fsType = "ext4";
    };

    "/nix" = {
      device = "/data/nix";
      fsType = "auto";
      options = [ "bind" ];
    };
    "/boot" = {
      device = "/data/boot";
      fsType = "auto";
      options = [ "bind" ];
    };
    "/dotfiles" = {
      device = "/data/dotfiles";
      fsType = "auto";
      options = [ "bind" ];
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
