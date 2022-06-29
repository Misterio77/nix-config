# This file (and the global directory) holds config that i use on all hosts
{ lib, inputs, hostname, ... }:
{
  imports = [
    ./fish.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./persist.nix
    ./sops.nix
    ./users.nix
  ];

  networking.hostName = hostname;

  # Add each flake input as a registry
  nix.registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

  # Activate home-manager environment, if not already
  environment.loginShellInit = ''
    [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null
  '';

  hardware.enableRedistributableFirmware = true;
  # boot.initrd.systemd.enable = true;

  system.stateVersion = lib.mkDefault "22.05";
}
