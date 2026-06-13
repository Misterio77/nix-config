{
  pkgs,
  config,
  lib,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  inherit (config.home-manager.users.gabriel.xdg) stateHome;
in {
  users.mutableUsers = false;
  users.users.gabriel = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ifTheyExist [
      "audio"
      "deluge"
      "docker"
      "git"
      "i2c"
      "libvirtd"
      "minecraft"
      "mysql"
      "wpa_supplicant"
      "plugdev"
      "podman"
      "tss"
      "video"
      "wheel"
      "wireshark"
    ];

    openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile ../../../../home/gabriel/ssh.pub);
    hashedPasswordFile = config.sops.secrets.gabriel-password.path;
    packages = [pkgs.home-manager];
  };

  sops.secrets = {
    gabriel-password = {
      sopsFile = ../../secrets.yaml;
      neededForUsers = true;
    };
    firefly-pat = {
      sopsFile = ../../secrets.yaml;
      owner = "gabriel";
      path = "${stateHome}/opencode/secrets/firefly-pat";
    };
    deepseek-apikey = {
      sopsFile = ../../secrets.yaml;
      owner = "gabriel";
      path = "${stateHome}/opencode/secrets/deepseek-apikey";
    };
  };

  home-manager.users.gabriel = import ../../../../home/gabriel/${config.networking.hostName}.nix;

  security.pam.services = {
    swaylock = {};
    hyprlock = {};
  };
}
