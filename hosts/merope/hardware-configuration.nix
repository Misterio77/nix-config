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
    fkms-3d = {
      enable = true;
      cma = 1024;
    };
  };
  hardware.graphics.enable = true;

  # Avoiding some heavy IO
  nix.settings.auto-optimise-store = false;

  # Enable argonone fan daemon
  services.hardware.argonone.enable = true;

  # Workaround for https://github.com/NixOS/nixpkgs/issues/154163
  nixpkgs.overlays = [
    (_: prev: {makeModulesClosure = x: prev.makeModulesClosure (x // {allowMissing = true;});})
  ];

  nixpkgs.hostPlatform.system = "aarch64-linux";

  powerManagement.cpuFreqGovernor = "powersave";
}
