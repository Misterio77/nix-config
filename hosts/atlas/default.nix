# System configuration for my main desktop PC
{ pkgs, inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ../common/global
    ../common/optional/ckb-next.nix
    ../common/optional/misterio-greetd.nix
    ../common/optional/pipewire.nix
    ../common/optional/podman.nix
    ../common/optional/postgres.nix
    ../common/optional/quietboot.nix
    ../common/optional/starcitizen-fixes.nix
    ../common/optional/steam.nix
    ../common/optional/systemd-boot.nix
    ../common/optional/tailscale.nix
  ];

  networking = {
    useDHCP = false;
    interfaces.enp8s0 = {
      useDHCP = true;
      wakeOnLan.enable = true;

      ipv4 = {
        addresses = [{
          address = "192.168.0.12";
          prefixLength = 24;
        }];
      };
      ipv6 = {
        addresses = [{
          address = "2804:14d:8084:a484::2";
          prefixLength = 64;
        }];
      };
    };
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  programs = {
    gamemode = {
      enable = true;
      settings.gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };

    adb.enable = true;
    dconf.enable = true;
    kdeconnect.enable = true;
  };

  services.dbus.packages = [ pkgs.gcr ];

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    wlr.enable = true;
  };

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ amdvlk ];
      driSupport = true;
    };
    openrgb.enable = true;
    opentabletdriver.enable = true;
  };

  system.stateVersion = "22.05";
}
