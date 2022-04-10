{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../common/btrfs-optin-persistence.nix
    ../common/encrypted-root.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "usbhid" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
      kernelModules = [ "kvm-intel" ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };
}
