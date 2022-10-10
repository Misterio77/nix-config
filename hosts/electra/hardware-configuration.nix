{
  imports = [
    ../common/optional/btrfs-optin-persistence.nix
  ];


  boot = {
    initrd = {
      availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
    };
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/vda";
      };
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/electra";
      fsType = "btrfs";
      options = [ "subvol=boot" ];
    };
  };

  hardware.cpu.intel.updateMicrocode = true;

  virtualisation.hypervGuest.enable = true;
  systemd.services.hv-kvp.unitConfig.ConditionPathExists = [ "/dev/vmbus/hv_kvp" ];

  nixpkgs.hostPlatform.system = "x86_64-linux";
}
