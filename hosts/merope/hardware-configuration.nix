{
  imports = [../common/optional/ephemeral-btrfs.nix];

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci"];
    };
    loader.timeout = 5;
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

    "/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };

    "/srv/media/tv" = {
      device = "/dev/disk/by-label/media";
      fsType = "btrfs";
      options = [
        "subvol=tv"
        "noatime"
      ];
    };

    "/srv/media/movies" = {
      device = "/dev/disk/by-label/media";
      fsType = "btrfs";
      options = [
        "subvol=movies"
        "noatime"
      ];
    };
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8196;
    }
  ];

  hardware.raspberry-pi."4" = {
    i2c1.enable = true;
    fkms-3d.enable = true;
  };

  nixpkgs.hostPlatform.system = "aarch64-linux";

  powerManagement.cpuFreqGovernor = "powersave";
}
