{modulesPath, ...}: {
  imports = [
    ../common/optional/ephemeral-btrfs.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "virtio_pci"
        "usbhid"
      ];
    };
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };
    # Enable nested virtualization
    extraModprobeConfig = "options kvm nested=1";
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8196;
    }
  ];

  nixpkgs.hostPlatform.system = "aarch64-linux";
}
