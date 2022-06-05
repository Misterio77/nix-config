# System configuration for my Raspberry Pi 4
{ inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4

    ./hardware-configuration.nix
    ../common
    ../common/modules/passwordless-sudo.nix
    ../common/modules/podman.nix
    ../common/modules/postgres.nix

    ./deluge.nix
    ./files-server.nix
    ./jitsi.nix
    ./minecraft.nix
    ./navidrome.nix
    ./nextcloud.nix
    ./nginx.nix
    ./wireguard.nix

    ./paste-misterio-me.nix
  ];

  # Static IP address
  networking = {
    useDHCP = false;
    interfaces.eth0 = {
      useDHCP = true;
      wakeOnLan.enable = true;

      ipv4.addresses = [{
        address = "192.168.77.11";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2804:14d:8084:a484::1";
        prefixLength = 64;
      }];
    };
  };

  # Enable argonone fan daemon
  hardware.argonone.enable = true;

  system.stateVersion = "22.05";
}
