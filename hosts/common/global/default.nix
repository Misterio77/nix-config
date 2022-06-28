# This file (and the global directory) holds config that i use on all hosts
{ lib, ... }:
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


  # Activate home-manager environment, if not already
  /*
  environment.loginShellInit = ''
    [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null
  '';
  */

  hardware.enableRedistributableFirmware = true;
  # boot.initrd.systemd.enable = true;

  system.stateVersion = lib.mkDefault "22.05";
}
