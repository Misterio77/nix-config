# System configuration for my main desktop PC
{ config, pkgs, system, inputs, ... }:

let nur = import inputs.nur { nurpkgs = import inputs.nixpkgs { inherit system; }; };
in
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
    nur.repos.misterio.modules.openrgb

    ./hardware-configuration.nix
    ../common
    ../common/misterio-greetd.nix
    ../common/pipewire.nix
    ../common/podman.nix
    ../common/postgres.nix
    ../common/steam.nix

    # ./satisfactory.nix
  ];

  networking.firewall.enable = false;
  boot = {
    # Kernel
    kernelPackages = pkgs.linuxPackages_zen;
    # Plymouth (currently only starts at phase 2)
    plymouth = {
      enable = true;
    };
    # Bootloader configuration
    loader = {
      timeout = 0;
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    # Allow compiling to ARM64
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    # Let's me play star citizen and lol
    kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "abi.vsyscall32" = 0;
    };
  };

  # Block eac cdn so i can play star citizen
  networking.extraHosts = ''
    127.0.0.1 modules-cdn.eac-prod.on.epicgames.com
  '';
  # Route traffic to VPN network through merope
  networking.interfaces.enp8s0 = {
    ipv4.routes = [{
      address = "10.100.0.1";
      prefixLength = 24;
      via = "192.168.77.10";
    }];
    ipv6.routes = [{
      address = "fdc9:281f:4d7:9ee9::1";
      prefixLength = 64;
      via = "2804:14d:8084:a484:ffff:ffff:ffff:ffff";
    }];
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
}
