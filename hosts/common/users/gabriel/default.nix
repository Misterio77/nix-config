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

    # Opencode secrets
    firefly-pat = {
      sopsFile = ../../secrets.yaml;
      owner = "gabriel";
    };
    deepseek-apikey = {
      sopsFile = ../../secrets.yaml;
      owner = "gabriel";
    };
    openai-free-apikey = {
      sopsFile = ../../secrets.yaml;
      owner = "gabriel";
    };
    pluggy-secret = {
      sopsFile = ../../secrets.yaml;
      owner = "gabriel";
    };

    # Private opencode skills
    gabs-info = {
      sopsFile = ../../../../home/gabriel/features/opencode/private.yaml;
      owner = "gabriel";
    };
    skill-lumis-private = {
      sopsFile = ../../../../home/gabriel/features/opencode/private.yaml;
      owner = "gabriel";
    };
    skill-firefly-private = {
      sopsFile = ../../../../home/gabriel/features/opencode/private.yaml;
      owner = "gabriel";
    };
  };

  home-manager.users.gabriel = import ../../../../home/gabriel/${config.networking.hostName}.nix;

  security.pam.services = {
    swaylock = {};
    hyprlock = {};
  };
}
