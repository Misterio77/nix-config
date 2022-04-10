# System configuration for my laptop
{ pkgs, inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ../common
    ../common/misterio-greetd.nix
    ../common/pipewire.nix
    ../common/postgres.nix
    ../common/steam.nix

    ./wireguard.nix
  ];


  networking.networkmanager.enable = true;

  boot = {
    # Kernel
    kernelPackages = pkgs.linuxPackages_zen;
    # Plymouth (currently only starts at phase 2)
    plymouth = {
      enable = true;
    };
    loader = {
      timeout = 0;
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    # Let's me play lol
    kernel.sysctl = {
      "abi.vsyscall32" = 0;
    };
  };

  services.dbus.packages = [ pkgs.gcr ];

  powerManagement.powertop.enable = true;
  programs = {
    light.enable = true;
    gamemode.enable = true;
    adb.enable = true;
    dconf.enable = true;
    kdeconnect.enable = true;
  };

  # Lid settings
  services.logind ={
    lidSwitch = "suspend";
    lidSwitchExternalPower = "lock";
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    wlr.enable = true;
  };
}
