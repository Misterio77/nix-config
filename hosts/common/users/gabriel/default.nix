{
  pkgs,
  config,
  lib,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
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
      "lxd"
      "minecraft"
      "mysql"
      "network"
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

  sops.secrets.gabriel-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  home-manager.users.gabriel = import ../../../../home/gabriel/${config.networking.hostName}.nix;

  security.pam.services = {
    swaylock = {};
    hyprlock = {};
  };
}
