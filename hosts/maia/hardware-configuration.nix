{
  imports = [
    ../common/optional/ephemeral-btrfs.nix
    ../common/optional/encrypted-root.nix
  ];
  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" ];
      kernelModules = [ "kvm-intel" ];
    };
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 8196;
  }];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
