# System configuration for my main desktop PC
{ config, nixpkgs, pkgs, hardware, nur, impermanence, system, ... }:

let
  nur-no-pkgs = import nur {
    nurpkgs = import nixpkgs { inherit system; };
  };
in
{
  imports = [
    hardware.nixosModules.common-cpu-amd
    hardware.nixosModules.common-gpu-amd
    hardware.nixosModules.common-pc-ssd
    impermanence.nixosModules.impermanence
    nur-no-pkgs.repos.misterio.modules.openrgb
    ../common.nix
    ./hardware-configuration.nix
    # ./gpu-overclock.nix
    # ./satisfactory.nix
    # ./droidcam.nix
  ];

  networking.hostName = "atlas";

  environment.persistence."/data" = {
    directories = [
      "/var/log"
      "/var/lib/containers"
      "/var/lib/systemd"
      "/var/lib/postgresql"
      "/srv"
    ];
  };

  boot = {
    # Kernel
    kernelPackages = pkgs.linuxPackages_zen;
    # Plymouth (currently only starts at phase 2)
    plymouth = {
      enable = true;
      font = "${pkgs.fira}/share/fonts/opentype/FiraSans-Regular.otf";
    };
    # More silent boot
    kernelParams = [ "quiet" "udev.log_priority=3" ];
    consoleLogLevel = 3;
    # Bootloader configuration
    loader = {
      timeout = 0;
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    # Allow compiling to ARM64
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    # Let's me play star citizen and lol
    kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "abi.vsyscall32" = 0;
    };
  };

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    dbus.packages = [ pkgs.gcr ];
    postgresql.enable = true;
  };

  programs = {
    gamemode = {
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

    # Use GPG as SSH
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    adb.enable = true;
    dconf.enable = true;
    kdeconnect.enable = true;
  };

  security = {
    # Global sudo caching
    sudo.extraConfig = ''
      Defaults timestamp_type=global
    '';
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
  };
  security.pam.services.swaylock = { };

  hardware = {
    ckb-next.enable = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ amdvlk ];
      driSupport = true;
    };
    openrgb.enable = true;
    opentabletdriver.enable = true;
    steam-hardware.enable = true;
  };

  virtualisation = {
    podman.enable = true;
  };

  # My user info
  users.users.misterio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
    passwordFile = "/data/home/misterio/.password";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDci4wJghnRRSqQuX1z2xeaUR+p/muKzac0jw0mgpXE2T/3iVlMJJ3UXJ+tIbySP6ezt0GVmzejNOvUarPAm0tOcW6W0Ejys2Tj+HBRU19rcnUtf4vsKk8r5PW5MnwS8DqZonP5eEbhW2OrX5ZsVyDT+Bqrf39p3kOyWYLXT2wA7y928g8FcXOZjwjTaWGWtA+BxAvbJgXhU9cl/y45kF69rfmc3uOQmeXpKNyOlTk6ipSrOfJkcHgNFFeLnxhJ7rYxpoXnxbObGhaNqn7gc5mt+ek+fwFzZ8j6QSKFsPr0NzwTFG80IbyiyrnC/MeRNh7SQFPAESIEP8LK3PoNx2l1M+MjCQXsb4oIG2oYYMRa2yx8qZ3npUOzMYOkJFY1uI/UEE/j/PlQSzMHfpmWus4o2sijfr8OmVPGeoU/UnVPyINqHhyAd1d3Iji3y3LMVemHtp5wVcuswABC7IRVVKZYrMCXMiycY5n00ch6XTaXBwCY00y8B3Mzkd7Ofq98YHc= (none)"
    ];
  };
}
