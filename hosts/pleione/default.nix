{
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/gabriel

    ../common/optional/pipewire.nix
    ../common/optional/quietboot.nix

    ./kodi.nix
  ];

  hardware.nvidia = {
    # Does not support maxwell gpu
    open = false;
    # No need to offload on a desktop
    prime.offload.enable = false;
  };

  networking = {
    hostName = "pleione";
    useDHCP = true;
  };

  boot = {
    binfmt.emulatedSystems = [
      "aarch64-linux"
      "i686-linux"
    ];
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
  };

  hardware.graphics.enable = true;

  system.stateVersion = "22.05";
}
