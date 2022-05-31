# System configuration for my main desktop PC
{ pkgs, inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ../common
    ../common/misterio-greetd.nix
    ../common/pipewire.nix
    ../common/podman.nix
    ../common/postgres.nix
    ../common/steam.nix

    # ./factorio.nix
  ];

  networking = {
    useDHCP = false;
    interfaces.enp8s0 = {
      useDHCP = true;
      wakeOnLan.enable = true;

      ipv4 = {
        addresses = [{
          address = "192.168.77.12";
          prefixLength = 24;
        }];
        routes = [{
          address = "10.100.0.0";
          prefixLength = 24;
          via = "192.168.77.11"; # Route traffic intended for the VPN through merope
        }];
      };
      ipv6 = {
        addresses = [{
          address = "2804:14d:8084:a484::2";
          prefixLength = 64;
        }];
        routes = [{
          address = "fdc9:281f:4d7:9ee9::";
          prefixLength = 64;
          via = "2804:14d:8084:a484::1"; # Route traffic intended for the VPN through merope
        }];
      };
    };

    # Block eac cdn so i can play star citizen
    extraHosts = ''
      127.0.0.1 modules-cdn.eac-prod.on.epicgames.com
    '';
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_5_18;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernel.sysctl = {
      # Star citizen fix
      "vm.max_map_count" = 16777216;
      # LoL fix
      "abi.vsyscall32" = 0;
    };
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
    ckb-next.enable = true;
    openrgb.enable = true;
    opentabletdriver.enable = true;
  };

  system.stateVersion = "22.05";
}
