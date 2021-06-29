{ fetchFromGithub, config, pkgs, ... }:

let hashed_password = import ./password.nix; in
{
  imports = [
    ./hardware-configuration.nix
    ./home.nix
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
    supportedFilesystems = ["btrfs"];
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    hostName = "thanatos";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Sao_Paulo";

  nixpkgs.overlays = [
    (self: super:
    {
      swaylock = super.swaylock.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "mortie";
          repo = "swaylock-effects";
          rev = "705166727786725f6c8503f794f401536946a407";
          sha256 = "162aic40dfvlrz40zbzmhcmggihcdymxrfljxb7j7i5qy38iflpg";
        };
      });
    })
    (self: super:
    {
      ethminer = super.ethminer.overrideAttrs (oldAttrs: rec {
        cudaSupport = false;
      });
    }
    )
  ];

  security.pam.services.swaylock = {};

  security.rtkit.enable = true;
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

  services.getty.autologinUser = "misterio";
  users = {
    mutableUsers = false;
    users.misterio = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      initialHashedPassword = "${hashed_password}";
    };
  };

  /*
  services.ethminer = {
    enable = true;
    pool = "eth-br.flexpool.io";
    rig = "misterio";
    toolkit = "opencl";
    wallet = "0x16EeE21f85c06D3B983533b32Eef82d963d24f9a";
    registerMail = "eu%40misterio.me";
  };
  */
  system.stateVersion = "21.05";
  
}
