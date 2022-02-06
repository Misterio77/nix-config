{ modulesPath, hostname, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../common/btrfs-optin-persistence.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" ];
    };
  };

  fileSystems = {
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

  powerManagement.cpuFreqGovernor = "ondemand";
}
