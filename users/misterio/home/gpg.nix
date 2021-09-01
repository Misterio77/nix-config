{ pkgs, ... }:
{
  home.packages = with pkgs; [ pinentry-gnome ];
  home.persistence."/data/home/misterio".directories = [
    ".gnupg"
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "149F16412997785363112F3DBD713BC91D51B831" ];
    pinentryFlavor = "gnome3";
  };

}
# vim: filetype=nix
