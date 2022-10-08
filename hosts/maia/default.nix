{ pkgs, inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/misterio.nix
    ../common/users/layla.nix

    ./services
    # ../common/optional/pantheon.nix
    # ../common/optional/x11-no-suspend.nix
    # ../common/optional/quietboot.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };

  networking = {
    useDHCP = false;
    interfaces.enp2s0 = {
      useDHCP = true;
      wakeOnLan.enable = true;

      ipv4 = {
        addresses = [{
          address = "192.168.0.13";
          prefixLength = 24;
        }];
      };
      ipv6 = {
        addresses = [{
          address = "2804:14d:8084:a484::3";
          prefixLength = 64;
        }];
      };
    };
  };

  networking.networkmanager.enable = false;

  i18n.defaultLocale = "pt_BR.UTF-8";
  hardware.nvidia.prime.offload.enable = false;
  system.stateVersion = "22.05";
}
