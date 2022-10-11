{
  imports = [
    ./services
    ./hardware-configuration.nix

    ../common/global
    ../common/users/misterio.nix
  ];

  # environment.persistence.enable = true;

  networking = {
    hostName = "electra";
    useDHCP = true;
  };
  system.stateVersion = "22.05";
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;
  # Increase swappiness
  boot.kernel.sysctl = {
    "vm.swappiness" = 80;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}

