# This file holds config that i use on all hosts
{ pkgs, inputs, ... }:

{
  system.stateVersion = "21.11";

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Sao_Paulo";

  networking.networkmanager.enable = true;

  nix = {
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nix-colors.flake = inputs.nix-colors;
    };
    trustedUsers = [ "root" "@wheel" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-references
      warn-dirty = false
    '';
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "daily";
    };
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        domain = true;
        workstation = true;
        userServices = true;
      };
    };
  };
  programs = {
    fuse.userAllowOther = true;
    fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };
  };
}
