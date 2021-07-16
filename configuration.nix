{ fetchFromGithub, config, pkgs, ... }:

{
  disabledModules = [ "services/misc/ethminer.nix" ];
  imports = [
    ./hardware-configuration.nix
    ./users
  ];

  fonts.fonts = with pkgs; [
    fira
  ];

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
    consoleLogLevel = 3;
    supportedFilesystems = ["btrfs"];
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

  nixpkgs.config.allowUnfree = true;

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Sao_Paulo";

  networking = {
    hostName = "thanatos";
    networkmanager.enable = true;
  };

  security.rtkit.enable = true;
  services.dbus.packages = [ pkgs.gcr ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gtk];
  };

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    promptInit = "";
  };

  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
  };

  programs.gamemode = {
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
  programs.steam.enable = true;
  programs.dconf.enable = true;
  virtualisation.docker.enable = true;
  hardware.ckb-next.enable = true;

  system.stateVersion = "21.11";
  
}
