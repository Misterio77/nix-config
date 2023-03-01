# System configuration for my laptop
{ pkgs, inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/misterio

    ../common/optional/wireless.nix
    ../common/optional/greetd.nix
    ../common/optional/pipewire.nix
  ];

  # environment.persistence.enable = true;

  # TODO: theme "greeter" user GTK instead of using misterio to login
  services.greetd.settings.default_session.user = "misterio";

  networking = {
    hostName = "electra";
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };

  services.dbus.packages = [ pkgs.gcr ];

  powerManagement.powertop.enable = true;
  programs = {
    light.enable = true;
    adb.enable = true;
    dconf.enable = true;
    kdeconnect.enable = true;
  };

  # Lid settings
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "lock";
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  hardware = {
    nvidia = {
      prime.offload.enable = false;
    modesetting.enable = true;
    open = true;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        nvidia-vaapi-driver
      ];
    };
  };

  system.stateVersion = "22.05";
}
