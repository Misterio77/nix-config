# This file holds config that i use on all hosts
{ lib, config, pkgs, inputs, persistence, ... }: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [
      "/var/log"
      "/var/lib/systemd"
      "/var/lib/acme"
      "/etc/NetworkManager/system-connections"
      "/srv"
      "/dotfiles"
    ];
  };

  i18n.defaultLocale = pkgs.lib.mkDefault "en_US.UTF-8";
  time.timeZone = "America/Sao_Paulo";

  environment = {
    # Activate home-manager environment, if not already enabled
    loginShellInit = ''
      [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null'';

    homeBinInPath = true;
    localBinInPath = true;
    etc."nixos" = {
      target = "nixos";
      source = "/dotfiles";
    };
  };

  boot = {
    # Quieter boot
    kernelParams =
      [ "quiet" "udev.log_priority=3" "vt.global_cursor_default=0" ];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  # Enable acme for usage with nginx vhosts
  security.acme = {
    defaults.email = "eu@misterio.me";
    acceptTerms = true;
  };

  nix = {
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://misterio.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "misterio.cachix.org-1:cURMcHBuaSihTQ4/rhYmTwbbfWO8AnZEu6w4aNs3iKE="
      ];

      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
    };
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';
    gc = {
      automatic = true;
      dates = "daily";
    };
  };

  services = {
    geoclue2.enable = true;
    pcscd.enable = true;
    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
      forwardX11 = true;
      # Persist host ssh keys
      hostKeys = lib.mkIf persistence [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = "4096";
        }
      ];
    };
    avahi = {
      enable = true;
      nssmdns = true;
      allowPointToPoint = true;
      publish = {
        enable = true;
        domain = true;
        workstation = true;
        userServices = true;
      };
      reflector = true;
      openFirewall = true;
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
