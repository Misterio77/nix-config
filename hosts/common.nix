# This file holds config that i use on all hosts
{ pkgs, nixpkgs, nix-colors, wallpapers, nur, declarative-cachix, ... }:

{
  imports = [
    declarative-cachix.nixosModules.declarative-cachix
  ];

  system.stateVersion = "21.11";

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Sao_Paulo";

  networking.networkmanager.enable = true;

  environment = {
    # Activate home-manager environment, if not already enabled
    loginShellInit = ''[ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate 2> /dev/null'';

    homeBinInPath = true;
    localBinInPath = true;
  };

  cachix = [
    {
      name = "misterio";
      sha256 = "1v4fn1m99brj9ydzzkk75h3f30rjmwz60czw2c1dnhlk6k1dsbih";
    }
  ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ nur.overlay wallpapers.overlay ];
  };

  nix = {
    registry = {
      nixpkgs.flake = nixpkgs;
      nix-colors.flake = nix-colors;
    };
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
