{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/misterio
  ];

  networking = {
    hostName = "celaeno";
    useDHCP = true;
  };
  system.stateVersion = "22.05";

  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
}

