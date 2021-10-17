# System configuration for my main desktop PC
{ config, nixpkgs, pkgs, hardware, nur, impermanence, system, ... }:

let
  nur-no-pkgs = import nur {
    nurpkgs = import nixpkgs { inherit system; };
  };
in
{
  imports = [
    hardware.nixosModules.common-cpu-amd
    hardware.nixosModules.common-gpu-amd
    hardware.nixosModules.common-pc-ssd
    impermanence.nixosModules.impermanence
    nur-no-pkgs.repos.misterio.modules.openrgb
    ./hardware-configuration.nix
    ../common.nix
  ];

  networking.hostName = "atlas";

  fileSystems."/data/var".neededForBoot = true;
  fileSystems."/data/home".neededForBoot = true;

  environment.persistence."/data" = {
    directories = [
      "/var/log"
      "/var/lib/docker"
      "/var/lib/systemd"
      "/var/lib/postgresql"
      "/srv"
    ];
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
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
    kernelModules = [ "v4l2loopback" "i2c-dev" "i2c-piix4" ];
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
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    dbus.packages = [ pkgs.gcr ];
    postgresql = {
      enable = true;
      authentication = pkgs.lib.mkOverride 12 ''
        local all all trust
      '';
    };
  };

  programs = {
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
      };
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    dconf.enable = true;
    # droidcam.enable = true;
    kdeconnect.enable = true;
  };

  security = {
    rtkit.enable = true;
    # Global sudo caching
    sudo.extraConfig = ''
      Defaults timestamp_type=global
    '';
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
  };
  security.pam.services.swaylock = { };

  environment.variables.OCL_ICD_VENDORS = "/run/opengl-driver";
  environment.etc.amdgpu-custom-state.card0.text = ''
    OD_SCLK:
    0: 800Mhz
    1: 2009Mhz
    OD_MCLK:
    1: 875MHz
    OD_VDDC_CURVE:
    0: 800MHz 720mV
    1: 1404MHz 827mV
    2: 2009MHz 1198mV
    OD_RANGE:
    SCLK:     800Mhz       2150Mhz
    MCLK:     625Mhz        950Mhz
    VDDC_CURVE_SCLK[0]:     800Mhz       2150Mhz
    VDDC_CURVE_VOLT[0]:     750mV        1200mV
    VDDC_CURVE_SCLK[1]:     800Mhz       2150Mhz
    VDDC_CURVE_VOLT[1]:     750mV        1200mV
    VDDC_CURVE_SCLK[2]:     800Mhz       2150Mhz
    VDDC_CURVE_VOLT[2]:     750mV        1200mV
  '';
  hardware = {
    ckb-next.enable = true;
    opengl.enable = true;
    openrgb.enable = true;
    opentabletdriver.enable = true;
    steam-hardware.enable = true;
  };

  virtualisation.docker.enable = true;



  # My user info
  users.users.misterio = {
    isNormalUser = true;
    extraGroups = [ "audio" "wheel" "docker" "plugdev" ];
    shell = pkgs.fish;
    # Grab hashed password from /data
    passwordFile = "/data/home/misterio/.password";
  };

  # Autologin me at tty1
  systemd.services."autovt@tty1" = {
    description = "Autologin at the TTY1";
    after = [ "systemd-logind.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = [
        "" # override upstream default with an empty ExecStart
        "@${pkgs.utillinux}/sbin/agetty agetty --login-program ${pkgs.shadow}/bin/login --autologin misterio --noclear %I $TERM"
      ];
      Restart = "always";
      Type = "idle";
    };
  };
}
