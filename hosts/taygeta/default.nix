{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/gabriel
  ];

  networking = {
    hostName = "taygeta";
    useDHCP = true;
  };
  system.stateVersion = "22.11";
  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;
}
