{
  imports = [
    ../common/optional/btrfs-optin-persistence.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "sr_mod" "uhci_hcd" "virtio_blk" "virtio_pci" ];
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

  hardware.cpu.intel.updateMicrocode = true;

  virtualisation.hypervGuest.enable = true;
  systemd.services.hv-kvp.unitConfig.ConditionPathExists = [ "/dev/vmbus/hv_kvp" ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
