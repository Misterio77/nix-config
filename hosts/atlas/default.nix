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
        host all all ::1/128 trust
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

  hardware = {
    ckb-next.enable = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        mesa.opencl
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
        rocm-runtime
      ];
      extraPackages32 = with pkgs; [
        mesa.opencl
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
        rocm-runtime
      ];
      driSupport = true;
      driSupport32Bit = true;
    };
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
