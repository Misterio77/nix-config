{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules =
        [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      luks.devices."nixenc".device =
        "/dev/disk/by-uuid/32d93839-2606-4472-a4ba-01b8510937bb";
    };
    kernelModules = [ "kvm-intel" ];
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=4G" "mode=755" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/96C2-490B";
      fsType = "vfat";
    };

    "/data" = {
      device = "/dev/disk/by-uuid/9ded8eaf-5411-425b-9664-1208aadd11b9";
      fsType = "btrfs";
      options = [ "subvol=data" "compress=zstd" ];
      neededForBoot = true;
    };

    "/dotfiles" = {
      device = "/dev/disk/by-uuid/9ded8eaf-5411-425b-9664-1208aadd11b9";
      fsType = "btrfs";
      options = [ "subvol=dotfiles" "compress=zstd" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/9ded8eaf-5411-425b-9664-1208aadd11b9";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };
  };
}
