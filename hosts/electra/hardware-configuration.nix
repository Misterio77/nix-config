{
  imports = [
    ../common/optional/btrfs-optin-persistence.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
    };
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/vda";
    };
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/electra";
    fsType = "btrfs";
    options = [ "subvol=boot" ];
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 12288;
  }];

  hardware.cpu.intel.updateMicrocode = true;

  virtualisation.hypervGuest.enable = true;
  systemd.services.hv-kvp.unitConfig.ConditionPathExists = [ "/dev/vmbus/hv_kvp" ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
