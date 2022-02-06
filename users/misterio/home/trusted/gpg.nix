{ pkgs, persistence, lib, ... }: {
  home.packages = with pkgs; [ pinentry-gnome ];

  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio".directories = [ ".gnupg" ];
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "149F16412997785363112F3DBD713BC91D51B831" ];
    pinentryFlavor = "gnome3";
  };

  programs.gpg = {
    enable = true;
  };

}
# vim: filetype=nix
