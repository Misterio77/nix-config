{inputs, ...}: {
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4

    ./services
    ./hardware-configuration.nix

    ../common/global
    ../common/optional/wireless.nix
    ../common/users/gabriel
  ];

  boot.initrd.systemd.emergencyAccess = true;

  # Static IP address
  networking = {
    hostName = "merope";
    useDHCP = true;
    interfaces = {
      # TODO change to eth0
      wlan0 = {
        useDHCP = true;
        wakeOnLan.enable = true;
        ipv4.addresses = [
          {
            address = "192.168.0.11";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "2804:14d:8082:877d::1";
            prefixLength = 64;
          }
        ];
      };
    };
  };

  # Avoiding some heavy IO
  nix.settings.auto-optimise-store = false;

  # Enable argonone fan daemon
  services.hardware.argonone.enable = true;

  # Workaround for https://github.com/NixOS/nixpkgs/issues/154163
  nixpkgs.overlays = [
    (_: prev: {makeModulesClosure = x: prev.makeModulesClosure (x // {allowMissing = true;});})
  ];

  system.stateVersion = "22.05";
}
