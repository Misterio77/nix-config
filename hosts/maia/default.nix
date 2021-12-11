# System configuration for my gf's desktop PC
{ config, pkgs, hardware, impermanence, ... }:

{
  imports = [
    hardware.nixosModules.common-cpu-intel
    hardware.nixosModules.common-pc-ssd
    impermanence.nixosModules.impermanence
    ../common.nix
    ./hardware-configuration.nix
  ];

  i18n.defaultLocale = "pt_BR.UTF-8";

  environment.systemPackages = with pkgs;
    [
      (steam.override {
        # Workaround for embedded browser not working.
        #
        # https://github.com/NixOS/nixpkgs/issues/137279
        extraPkgs = pkgs: with pkgs; [ pango harfbuzz libthai ];

        # Workaround for an issue with VK_ICD_FILENAMES on nvidia hardware:
        #
        # - https://github.com/NixOS/nixpkgs/issues/126428 (bug)
        # - https://github.com/NixOS/nixpkgs/issues/108598#issuecomment-858095726 (workaround)
        extraProfile = ''
          unset VK_ICD_FILENAMES
          export VK_ICD_FILENAMES=${config.hardware.nvidia.package}/share/vulkan/icd.d/nvidia_icd.json:${config.hardware.nvidia.package.lib32}/share/vulkan/icd.d/nvidia_icd32.json:$VK_ICD_FILENAMES
        '';
      })
    ];

  environment.persistence."/data" = {
    directories = [ "/var/log" "/var/lib/systemd" ];
  };

  boot = {
    plymouth.enable = true;
    kernelPackages = pkgs.linuxPackages_zen;
    supportedFilesystems = [ "btrfs" ];
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
    dbus.packages = [ pkgs.gcr ];
    xserver = {
      enable = true;
      displayManager.gdm = { enable = true; };
      desktopManager.gnome.enable = true;
      videoDrivers = [ "nvidia" ];
    };
  };

  programs = {
    steam.enable = true;
    dconf.enable = true;
  };

  security = { rtkit.enable = true; };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
  };

  hardware = {
    nvidia.package = config.boot.kernelPackages.nvidia_x11;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    steam-hardware.enable = true;
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
  };
}
