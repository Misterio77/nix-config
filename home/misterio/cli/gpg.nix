{ pkgs, persistence, desktop, lib, config, ... }: {
  home.packages =
    if desktop != null
    then [ pkgs.pinentry-gnome ]
    else [ pkgs.pinentry-curses ];

  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio".directories = [ ".gnupg" ];
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "149F16412997785363112F3DBD713BC91D51B831" ];
    pinentryFlavor = if desktop != null then "gnome3" else "curses";
    enableExtraSocket = true;
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.home.homeDirectory}/.gnupg";
  };

}
# vim: filetype=nix
