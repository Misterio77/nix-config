{
  imports = [
    ./services
    ./hardware-configuration.nix

    ../common/global
    ../common/users/misterio
    ../common/optional/fail2ban.nix
  ];

  networking = {
    hostName = "alcyone";
    useDHCP = true;
  };
  system.stateVersion = "22.05";
}

