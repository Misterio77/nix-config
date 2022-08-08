{
  imports = [
    ./hardware-configuration.nix
    ../common/global
    ../common/optional/acme.nix
    ../common/optional/podman.nix
    ../common/optional/tailscale.nix
    ./services
  ];

  networking.useDHCP = true;
  system.stateVersion = "22.05";
}

