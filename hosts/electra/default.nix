{ pkgs, ... }:
{
  imports = [
    ./services
    ./hardware-configuration.nix

    ../common/global
    ../common/users/misterio.nix
  ];

  networking.useDHCP = true;
  system.stateVersion = "22.05";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_hardened;
}

