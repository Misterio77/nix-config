{
  inputs,
  config,
  lib,
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
    ../common/optional/regreet.nix
    ../common/optional/steam-gamescope-session.nix
    ../common/optional/jellyfin-firefox-session.nix

    ./media-user.nix
  ];

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

  powerManagement.powertop.enable = true;

  programs = {
    adb.enable = true;
    dconf.enable = true;
  };

  services.logind = {
    powerKey = "suspend";
    powerKeyLongPress = "poweroff";
  };

  hardware.graphics.enable = true;

  system.stateVersion = "22.05";
}
