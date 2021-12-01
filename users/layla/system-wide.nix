{ pkgs, ... }:
{
  users.users.layla = {
    isNormalUser = true;
    shell = pkgs.fish;
    passwordFile = "/data/home/layla/.password";
    extraGroups = [  "networkmanager" "audio" "wheel" ];
  };
}
