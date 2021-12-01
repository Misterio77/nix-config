# This file holds config that i use on all hosts
{ pkgs, lib, nixpkgs, declarative-cachix, ... }:

{
  imports = [
    declarative-cachix.nixosModules.declarative-cachix
  ];

  system.stateVersion = "21.11";

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = "America/Sao_Paulo";

  networking.networkmanager.enable = true;

  environment = {
    # Activate home-manager environment, if not already enabled
    loginShellInit = ''[ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null'';

    homeBinInPath = true;
    localBinInPath = true;
  };

  cachix = [
    {
      name = "misterio";
      sha256 = "1v4fn1m99brj9ydzzkk75h3f30rjmwz60czw2c1dnhlk6k1dsbih";
    }
  ];

  boot = {
    # Quieter boot
    kernelParams = [ "quiet" "udev.log_priority=3" "vt.global_cursor_default=0" ];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  # Enable acme for usage with nginx vhosts
  security.acme = {
    email = "eu@misterio.me";
    acceptTerms = true;
  };

  nix = {
    trustedUsers = [ "root" "@wheel" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-references
      warn-dirty = false
    '';
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "daily";
    };
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
      forwardX11 = true;
      # Persist host ssh keys
      hostKeys = [
        {
          path = "/data/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/data/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = "4096";
        }
      ];
    };
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        domain = true;
        workstation = true;
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
  };
}
