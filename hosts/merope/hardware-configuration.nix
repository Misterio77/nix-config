{
  imports = [
    ../common/optional/btrfs-optin-persistence.nix
  ];


  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" ];
    };
    loader.timeout = 5;
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "ext4";
      neededForBoot = true;
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

  hardware.raspberry-pi."4".i2c1.enable = true;

  nixpkgs.hostPlatform.system = "aarch64-linux";

  powerManagement.cpuFreqGovernor = "ondemand";
}
