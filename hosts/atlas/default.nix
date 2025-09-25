{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/gabriel

    ../common/optional/peripherals.nix
    ../common/optional/regreet.nix
    ../common/optional/pipewire.nix
    ../common/optional/quietboot.nix
    ../common/optional/wireless.nix
    ../common/optional/lxd.nix

    ../common/optional/starcitizen-fixes.nix
  ];

  networking = {
    hostName = "atlas";
    useDHCP = true;
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    binfmt.emulatedSystems = [
      "aarch64-linux"
      "i686-linux"
    ];
  };

  powerManagement.powertop.enable = true;
  programs = {
    adb.enable = true;
    dconf.enable = true;
  };

  hardware.graphics.enable = true;

  system.stateVersion = "22.05";
}
