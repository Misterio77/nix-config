{ pkgs, ... }: {
  users.users.layla = {
    isNormalUser = true;
    shell = pkgs.fish;
    passwordFile = "/persist/home/layla/.password";
    extraGroups = [ "networkmanager" "audio" "wheel" ];
  };
}
