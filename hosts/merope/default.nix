# System configuration for my Raspberry Pi 4
{ inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4

    ./hardware-configuration.nix
    ../common/global
    ../common/optional/acme.nix
    ../common/optional/podman.nix
    ../common/optional/postgres.nix
    ./services
  ];

  # Static IP address
  networking = {
    useDHCP = false;
    interfaces.eth0 = {
      useDHCP = true;
      wakeOnLan.enable = true;

      ipv4.addresses = [{
        address = "192.168.0.11";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2804:14d:8084:a484::1";
        prefixLength = 64;
      }];
    };
  };

  boot.loader.timeout = 5;

  # Enable argonone fan daemon
  services.hardware.argonone.enable = true;

  system.stateVersion = "22.05";
}
