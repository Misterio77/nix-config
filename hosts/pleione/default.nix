{
  inputs,
  config,
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

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    powerManagement.enable = true;
    # Does not support maxwell gpu
    open = false;
    # No need to offload on a desktop
    prime.offload.enable = false;
  };
  # Try to fix broken suspend
  systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";

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
