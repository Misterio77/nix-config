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
    ../common/docker.nix
    ../common/misterio-greetd.nix
    ../common/pipewire.nix
    ../common/postgres.nix
    ../common/steam.nix

    # ./satisfactory.nix
  ];

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

  programs = {
    gamemode = {
      enable = true;
      settings = {
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
        custom = {
          start = "${pkgs.systemd}/bin/systemctl --user stop ethminer";
          end = "${pkgs.systemd}/bin/systemctl --user start ethminer";
        };
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
