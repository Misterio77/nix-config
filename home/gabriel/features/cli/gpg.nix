{
  pkgs,
  config,
  lib,
  ...
}: {
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = ["149F16412997785363112F3DBD713BC91D51B831"];
    enableExtraSocket = true;
    pinentryPackage =
      if config.gtk.enable
      then pkgs.pinentry-gnome3
      else pkgs.pinentry-tty;
  };

  home.packages = lib.optional config.gtk.enable pkgs.gcr;

  programs = let
    fixGpg =
      /*
      bash
      */
      ''
        gpgconf --launch gpg-agent
      '';
  in {
    # Start gpg-agent if it's not running or tunneled in
    # SSH does not start it automatically, so this is needed to avoid having to use a gpg command at startup
    # https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
    bash.profileExtra = fixGpg;
    fish.loginShellInit = fixGpg;
    zsh.loginExtra = fixGpg;
    nushell.extraLogin = fixGpg;

    gpg = {
      enable = true;
      settings = {
        trust-model = "tofu+pgp";
      };
      publicKeys = [
        {
          source = ../../pgp.asc;
          trust = 5;
        }
      ];
    };
  };

  systemd.user.services = {
    # Link /run/user/$UID/gnupg to ~/.gnupg-sockets
    # So that SSH config does not have to know the UID
    link-gnupg-sockets = {
      Unit = {
        Description = "link gnupg sockets from /run to /home";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/ln -Tfs /run/user/%U/gnupg %h/.gnupg-sockets";
        ExecStop = "${pkgs.coreutils}/bin/rm $HOME/.gnupg-sockets";
        RemainAfterExit = true;
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
# vim: filetype=nix

