{ pkgs, lib, config, ... }:
{
  imports = [ ./packages.nix ];

  users.mutableUsers = false;
  users.users.layla = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
    ];
    passwordFile = config.sops.secrets.layla-password.path;
  };

  sops.secrets.layla-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  # Persist entire home
  environment.persistence = {
    "/persist".directories = [ "/home/layla" ];
  };
}
