# System configuration for my laptop
{ config, pkgs, hardware, impermanence, system, ... }:

{
  imports = [
    hardware.nixosModules.common-cpu-amd
    hardware.nixosModules.common-gpu-amd
    hardware.nixosModules.common-pc-ssd
    impermanence.nixosModules.impermanence
    ../common.nix
    ./hardware-configuration.nix
    ./wireguard.nix
  ];

  environment.persistence."/data" = {
    directories = [
      "/var/log"
      "/var/lib/containers"
      "/var/lib/systemd"
      "/var/lib/postgresql"
      "/srv"
    ];
  };

  boot = {
    # Kernel
    kernelPackages = pkgs.linuxPackages_zen;
    # Plymouth (currently only starts at phase 2)
    plymouth = {
      enable = true;
      font = "${pkgs.fira}/share/fonts/opentype/FiraSans-Regular.otf";
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
  };

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    dbus.packages = [ pkgs.gcr ];
    postgresql.enable = true;
  };

  powerManagement.powertop.enable = true;
  programs = {
    light.enable = true;

    gamemode.enable = true;

    # Use GPG as SSH
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    adb.enable = true;
    dconf.enable = true;
    kdeconnect.enable = true;
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    wlr.enable = true;
  };

  hardware.steam-hardware.enable = true;

  virtualisation = {
    podman.enable = true;
  };
}
