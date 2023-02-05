{
  imports = [
    ./services
    ./hardware-configuration.nix

    ../common/global
    ../common/users/misterio
  ];

  networking = {
    hostName = "alcyone";
    useDHCP = true;
  };
  system.stateVersion = "22.05";
}

