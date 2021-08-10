{ pkgs, ... }: {
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "149F16412997785363112F3DBD713BC91D51B831" ];
    pinentryFlavor = "gtk2";
  };

}
# vim: filetype=nix
