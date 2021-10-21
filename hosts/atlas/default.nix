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
    /*
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    */
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
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    dconf.enable = true;
    # droidcam.enable = true;
    kdeconnect.enable = true;

    gamemode = {
      enable = true;
      settings = {
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
        custom =
        let
          startHook = pkgs.writeShellScriptBin "start-hook.sh" ''
            ${pkgs.systemd}/bin/systemctl --user stop ethminer
            SUDO_ASKPASS=${pkgs.zenity-askpass}/bin/zenity-askpass /run/wrappers/bin/sudo -A USER_STATES_PATH=/etc/default/amdgpu-gaming-state ${pkgs.amdgpu-clocks}/bin/amdgpu-clocks
          '';
          endHook = pkgs.writeShellScriptBin "end-hook.sh" ''
            ${pkgs.systemd}/bin/systemctl --user start ethminer
            # SUDO_ASKPASS=${pkgs.zenity-askpass}/bin/zenity-askpass /run/wrappers/bin/sudo -A USER_STATES_PATH=/etc/default/amdgpu-custom-state ${pkgs.amdgpu-clocks}/bin/amdgpu-clocks
          '';
        in {
          start = "${startHook}/bin/start-hook.sh";
          end = "${endHook}/bin/end-hook.sh";
        };
      };
    };
  };

  security = {
    rtkit.enable = true;
    # Global sudo caching
    sudo.extraConfig = ''
      Defaults timestamp_type=global
    '';
  };
  environment.etc = {
    "default/amdgpu-custom-state.card0".text = ''
      OD_SCLK:
      1: 1400Mhz
      OD_MCLK:
      1: 890MHz
      OD_VDDC_CURVE:
      0: 1400MHz 836mV

      FORCE_POWER_CAP: 150000000
    '';
    "default/amdgpu-gaming-state.card0".text = ''
      OD_SCLK:
      1: 2009Mhz
      OD_MCLK:
      1: 875MHz
      OD_VDDC_CURVE:
      0: 800MHz 780mV
      1: 1404MHz 826mV
      2: 2009MHz 1197mV

      FORCE_PERF_LEVEL: auto
      FORCE_POWER_CAP: 190000000
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
    opengl.enable = true;
    openrgb.enable = true;
    opentabletdriver.enable = true;
    steam-hardware.enable = true;
    pulseaudio.enable = true;
  };

  virtualisation.docker.enable = true;



  # My user info
  users.users.misterio = {
    isNormalUser = true;
    extraGroups = [ "audio" "wheel" "docker" "plugdev" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDci4wJghnRRSqQuX1z2xeaUR+p/muKzac0jw0mgpXE2T/3iVlMJJ3UXJ+tIbySP6ezt0GVmzejNOvUarPAm0tOcW6W0Ejys2Tj+HBRU19rcnUtf4vsKk8r5PW5MnwS8DqZonP5eEbhW2OrX5ZsVyDT+Bqrf39p3kOyWYLXT2wA7y928g8FcXOZjwjTaWGWtA+BxAvbJgXhU9cl/y45kF69rfmc3uOQmeXpKNyOlTk6ipSrOfJkcHgNFFeLnxhJ7rYxpoXnxbObGhaNqn7gc5mt+ek+fwFzZ8j6QSKFsPr0NzwTFG80IbyiyrnC/MeRNh7SQFPAESIEP8LK3PoNx2l1M+MjCQXsb4oIG2oYYMRa2yx8qZ3npUOzMYOkJFY1uI/UEE/j/PlQSzMHfpmWus4o2sijfr8OmVPGeoU/UnVPyINqHhyAd1d3Iji3y3LMVemHtp5wVcuswABC7IRVVKZYrMCXMiycY5n00ch6XTaXBwCY00y8B3Mzkd7Ofq98YHc= (none)"
    ];
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
