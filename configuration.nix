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

  programs.steam.enable = true;
  programs.gamemode.enable = true;
  programs.dconf.enable = true;
  virtualisation.docker.enable = true;
  hardware.ckb-next.enable = true;
  hardware.opengl.enable = true;

  system.stateVersion = "21.11";
  
}
