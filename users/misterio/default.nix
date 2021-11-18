{ lib, features, nur, pkgs, ... }:

{
  imports = [ ./rice.nix ] ++
    # Import each feature requested
    lib.forEach features (f: ./features + "/${f}");

  # Needed for basic operations
  programs = {
    home-manager.enable = true;
    git.enable = true;
  };
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ nur.overlay ];
  };
  systemd.user.startServices = "sd-switch";
}
