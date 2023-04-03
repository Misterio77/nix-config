{ pkgs, inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/misterio
    ../common/users/layla

    ../common/optional/pantheon.nix
    ../common/optional/quietboot.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    binfmt.emulatedSystems = [ "aarch64-linux" "i686-linux" ];
  };

  networking = {
    hostName = "maia";
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

  i18n.defaultLocale = "pt_BR.UTF-8";
  hardware.nvidia.prime.offload.enable = false;

  boot.kernelModules = [ "coretemp" ];
  services.thermald.enable = true;
  environment.etc."sysconfig/lm_sensors".text = ''
    HWMON_MODULES="coretemp"
  '';

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  system.stateVersion = "22.05";
}
