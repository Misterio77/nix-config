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

    ../common/optional/ckb-next.nix
    ../common/optional/greetd.nix
    ../common/optional/pipewire.nix
    ../common/optional/quietboot.nix
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

  programs = {
    adb.enable = true;
    dconf.enable = true;
  };

  services.hardware.openrgb.enable = true;
  hardware = {
    opengl.enable = true;
    opentabletdriver.enable = true;
  };

  system.stateVersion = "22.05";
}
