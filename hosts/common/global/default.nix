# This file (and the global directory) holds config that i use on all hosts
{ lib, inputs, hostname, persistence, config, ... }:
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

  nix = {
    # Add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Map registries to channels
    # Very useful when using legacy commands
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

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

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];

  system.stateVersion = lib.mkDefault "22.05";
}
