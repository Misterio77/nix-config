{ lib, features, pkgs, ... }:

{
  imports = [ ./rice.nix ] ++
    # Import each feature requested
    lib.forEach features (f: ./features + "/${f}");

  # Needed for basic operations
  programs = {
    home-manager.enable = true;
    git.enable = true;
  };
  systemd.user.startServices = "sd-switch";
}
