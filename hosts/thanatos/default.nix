{ config, pkgs, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ../../users ];

  system.stateVersion = "21.11";

  nixpkgs = { config.allowUnfree = true; };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  networking = {
    hostName = "thanatos";
    networkmanager.enable = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Sao_Paulo";

  boot = {
    plymouth = {
      enable = true;
      font = "${pkgs.fira}/share/fonts/opentype/FiraSans-Regular.otf";
    };
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [ "quiet" "udev.log_priority=3" ];
    kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "abi.vsyscall32" = 0;
    };
    kernelModules = [ "v4l2loopback" ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label=a7III
    '';
    consoleLogLevel = 3;
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
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    postgresql = {
      enable = true;
      authentication = pkgs.lib.mkOverride 12 ''
        local all all trust
        host all all ::1/128 trust
      '';
    };
  };

  programs = {
    zsh = {
      enable = true;
      enableBashCompletion = true;
      enableCompletion = true;
      promptInit = "";
    };

    ssh.startAgent = false;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

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
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    dconf.enable = true;
    droidcam.enable = true;
  };

  security.rtkit.enable = true;

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gtk ];
  };

  hardware = {
    ckb-next.enable = true;
    steam-hardware.enable = true;
  };

  virtualisation.docker.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/108598
  environment.systemPackages = with pkgs;
    [
      (steam.override {
        extraProfile = ''
          unset VK_ICD_FILENAMES
          export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json:/usr/share/vulkan/icd.d/radeon_icd.i686.json:${pkgs.amdvlk}/share/vulkan/icd.d/amd_icd64.json:${pkgs.driversi686Linux.amdvlk}/share/vulkan/icd.d/amd_icd32.json
        '';
      })
    ];
}
