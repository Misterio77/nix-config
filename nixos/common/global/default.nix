# This file (and the global directory) holds config that i use on all hosts
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

  system = {
    stateVersion = "22.05";
    # Activate home-manager config when booting
    userActivationScripts = {
      activate-hm.text = "/nix/var/nix/profiles/per-user/$USER/home-manager/activate";
    };
  };
}
