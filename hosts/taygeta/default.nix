{
  imports = [
    ./hardware-configuration.nix
    ./services

    ../common/global
    ../common/users/gabriel
  ];

  networking = {
    hostName = "taygeta";
    useDHCP = true;
  };
  system.stateVersion = "22.11";
}
