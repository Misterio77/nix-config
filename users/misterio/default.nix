{ pkgs, ... }:

{
  users.users.misterio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
    initialHashedPassword = import ./password.nix;
  };
}
