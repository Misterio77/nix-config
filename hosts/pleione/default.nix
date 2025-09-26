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
    ../common/optional/keyd.nix
    ../common/optional/steam-gamescope-session.nix
    ../common/optional/jellyfin-firefox-session.nix

    ./media-user.nix
  ];

  networking = {
    hostName = "pleione";
    useDHCP = true;
  };

   services.udev.extraRules = ''
     # disable USB auto suspend for remote control
     ACTION=="bind", SUBSYSTEM=="usb", ATTR{idVendor}=="1d6b", ATTR{idProduct}=="0002", TEST=="power/control", ATTR{power/control}="on"
     ACTION=="bind", SUBSYSTEM=="usb", ATTR{idVendor}=="1d6b", ATTR{idProduct}=="0003", TEST=="power/control", ATTR{power/control}="on"
   '';

  powerManagement.powertop.postStart = ''
   ${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=1d6b -a idProduct=0002
   ${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=1d6b -a idProduct=0003
  '';

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
