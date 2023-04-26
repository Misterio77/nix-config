{ pkgs, config, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;
  users.users.misterio = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
    ] ++ ifTheyExist [
      "network"
      "wireshark"
      "i2c"
      "mysql"
      "docker"
      "podman"
      "git"
      "libvirtd"
      "deluge"
    ];

    openssh.authorizedKeys.keyFiles = [ ../../../../home/misterio/ssh.pub ];
    passwordFile = config.sops.secrets.misterio-password.path;
    packages = [ pkgs.home-manager ];
  };

  sops.secrets.misterio-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  home-manager.users.misterio = import ../../../../home/misterio/${config.networking.hostName}.nix;

  services.geoclue2.enable = true;
  security.pam.services = { swaylock = { }; };
}
