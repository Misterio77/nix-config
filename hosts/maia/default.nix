# System configuration for my gf's desktop PC
{ config, nixpkgs, pkgs, hardware, nur, impermanence, system, ... }:

{
  imports = [
    hardware.nixosModules.common-cpu-intel
    hardware.nixosModules.common-pc-ssd
    impermanence.nixosModules.impermanence
    ./hardware-configuration.nix
    ../common.nix
  ];

  networking.hostName = "maia";
  i18n.defaultLocale = "pt_BR.UTF-8";

  fileSystems."/data".neededForBoot = true;

  environment.persistence."/data" = {
    directories = [
      "/var/log"
      "/var/lib/systemd"
    ];
  };

  boot = {
    plymouth.enable = true;
    kernelPackages = pkgs.linuxPackages_zen;
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
    dbus.packages = [ pkgs.gcr ];
    xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
      };
      desktopManager.gnome.enable = true;
      videoDrivers = [ "nvidia" ];
    };
  };

  programs = {
    steam.enable = true;
    dconf.enable = true;
  };

  security = {
    rtkit.enable = true;
  };


  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
  };

  hardware = {
    opengl.enable = true;
    steam-hardware.enable = true;
    pulseaudio.enable = true;
  };

  # User info
  users.users = {
    misterio = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
      passwordFile = "/data/home/misterio/.password";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDci4wJghnRRSqQuX1z2xeaUR+p/muKzac0jw0mgpXE2T/3iVlMJJ3UXJ+tIbySP6ezt0GVmzejNOvUarPAm0tOcW6W0Ejys2Tj+HBRU19rcnUtf4vsKk8r5PW5MnwS8DqZonP5eEbhW2OrX5ZsVyDT+Bqrf39p3kOyWYLXT2wA7y928g8FcXOZjwjTaWGWtA+BxAvbJgXhU9cl/y45kF69rfmc3uOQmeXpKNyOlTk6ipSrOfJkcHgNFFeLnxhJ7rYxpoXnxbObGhaNqn7gc5mt+ek+fwFzZ8j6QSKFsPr0NzwTFG80IbyiyrnC/MeRNh7SQFPAESIEP8LK3PoNx2l1M+MjCQXsb4oIG2oYYMRa2yx8qZ3npUOzMYOkJFY1uI/UEE/j/PlQSzMHfpmWus4o2sijfr8OmVPGeoU/UnVPyINqHhyAd1d3Iji3y3LMVemHtp5wVcuswABC7IRVVKZYrMCXMiycY5n00ch6XTaXBwCY00y8B3Mzkd7Ofq98YHc= (none)"
      ];
    };
    layla = {
      isNormalUser = true;
      extraGroups = [ "audio" "wheel" ];
      shell = pkgs.fish;
      passwordFile = "/data/home/layla/.password";
    };
  };
}
