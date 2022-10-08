{
  imports = [
    ./services
    ./hardware-configuration.nix

    ../common/global
    ../common/users/misterio.nix
  ];

  networking.useDHCP = true;
  system.stateVersion = "22.05";
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}

