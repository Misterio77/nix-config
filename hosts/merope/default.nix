{ config, pkgs, nixpkgs, hardware, nur, ... }:

{
  imports = [
    hardware.raspberry-pi-4
    ./hardware-configuration.nix
    ./minecraft.nix
  ];

  # Require /data/var to be mounted at boot
  fileSystems."/data".neededForBoot = true;

  environment.persistence."/data" = {
    directories = [
      "/var/log"
      "/var/lib/systemd"
      "/srv"
    ];
  };
  system.stateVersion = "21.11";

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ nur.overlay ];
  };

  cachix = [
    {
      name = "misterio";
      sha256 = "1v4fn1m99brj9ydzzkk75h3f30rjmwz60czw2c1dnhlk6k1dsbih";
    }
  ];

  nix = {
    trustedUsers = [ "misterio" ];
    package = pkgs.nixUnstable;
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "daily";
    };
    extraOptions = ''
      experimental-features = nix-command flakes ca-references
      warn-dirty = false
    '';
    registry.nixpkgs.flake = nixpkgs;
  };

  networking = {
    hostName = "merope";
    networkmanager.enable = true;
  };

  security = {
    # Passwordless sudo (for remote build)
    sudo.extraConfig = ''
      %wheel         ALL = (ALL) NOPASSWD: ALL
    '';
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Sao_Paulo";

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
  };

  programs = {
    fuse.userAllowOther = true;
    fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };

    ssh.startAgent = true;
  };
}
