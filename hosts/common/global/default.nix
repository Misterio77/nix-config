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

  environment = {
    loginShellInit = ''
      # Activate home-manager environment, if not already
      [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null
    '';

    # Persist logs, timers, etc
    persistence = lib.mkIf persistence {
      "/persist".directories = [ "/var/lib/systemd" "/var/log" ];
    };

    # Add terminfo files
    enableAllTerminfo = true;
  };

  # Allows users to allow others on their binds
  programs.fuse.userAllowOther = true;

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = lib.mkDefault "22.05";
}
