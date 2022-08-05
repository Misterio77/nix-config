{
  imports = [
    ./hardware-configuration.nix
    ../common/global
    ../common/optional/acme.nix
    ../common/optional/podman.nix
    ../common/optional/tailscale.nix
    ./services
  ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/vda";
    };
  };

  system.stateVersion = "22.05";
}

