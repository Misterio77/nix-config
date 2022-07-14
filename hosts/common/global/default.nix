# This file (and the global directory) holds config that i use on all hosts
{ lib, inputs, hostname, persistence, ... }:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./fish.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./peerix.nix
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

  # Persist logs, timers, etc
  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [ "/var/lib/systemd" "/var/logs" ];
  };

  # Allows users to allow others on their binds
  programs.fuse.userAllowOther = true;

  system.stateVersion = lib.mkDefault "22.05";
}
