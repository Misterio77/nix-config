{ fetchFromGithub, config, pkgs, ... }:

{
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
    kernelModules = [
      "v4l2loopback"
    ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label=a7III
    '';
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
  nixpkgs.overlays = [
    (import ./pkgs)
  ];

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

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
  services.postgresql = {
    enable = true;
    authentication = pkgs.lib.mkOverride 12 ''
      local all all trust
      host all all ::1/128 trust
    '';
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gtk];
  };

  programs.droidcam.enable = true;
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

  # https://github.com/NixOS/nixpkgs/issues/108598
  environment.systemPackages = with pkgs; [
    (steam.override {
      extraProfile = ''
        unset VK_ICD_FILENAMES
        export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json:/usr/share/vulkan/icd.d/radeon_icd.i686.json:${pkgs.amdvlk}/share/vulkan/icd.d/amd_icd64.json:${pkgs.driversi686Linux.amdvlk}/share/vulkan/icd.d/amd_icd32.json
      '';
    })
  ];

  programs.dconf.enable = true;
  virtualisation.docker.enable = true;
  hardware.ckb-next.enable = true;

  system.stateVersion = "21.11";

  # Wireguard
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };
  networking.wg-quick.interfaces = {
    #wg0 = import ./wg0.nix;
  };
}
