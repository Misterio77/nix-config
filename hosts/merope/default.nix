{ config, pkgs, nixpkgs, hardware, nur, ... }:

{
  imports = [
    ./hardware-configuration.nix
    hardware.raspberry-pi-4
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

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Sao_Paulo";

  boot.supportedFilesystems = [ "btrfs" ];

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

  /*
  hardware.deviceTree.overlays = [
    {
      # https://github.com/NixOS/nixpkgs/issues/135828#issuecomment-918359063
      name = "issuecomment-918359063";
      dtsText = ''
        // SPDX-License-Identifier: GPL-2.0
        /dts-v1/;
        /plugin/;
        / {
            compatible = "brcm,bcm2711";
            fragment@1 {
                target = <&emmc2bus>;
                __overlay__ {
                    dma-ranges = <0x00 0x00 0x00 0x00 0xfc000000>;
                };
            };
        };
      '';
    }
  ];
  */
}
