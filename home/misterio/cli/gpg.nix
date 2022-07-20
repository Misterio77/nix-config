{ pkgs, config, persistence, lib, ... }:
let
  fetchKey = { url, sha256 ? lib.fakeSha256 }:
    builtins.fetchurl { inherit sha256 url; };

  pinentry =
    if config.gtk.enable then {
      package = pkgs.pinentry-gnome;
      name = "gnome3";
    } else {
      package = pkgs.pinentry-curses;
      name = "curses";
    };
in
{
  home.packages = [ pinentry.package ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "149F16412997785363112F3DBD713BC91D51B831" ];
    pinentryFlavor = pinentry.name;
    enableExtraSocket = true;
  };

  programs = {
    # Start gpg-agent if it's not running or tunneled in
    # SSH does not start it automatically, so this is needed to avoid having to use a gpg command at startup
    # https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
    bash.profileExtra = "gpgconf --launch gpg-agent";
    fish.loginShellInit = "gpgconf --launch gpg-agent";
    zsh.loginExtra = "gpgconf --launch gpg-agent";
  };

  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio".directories = [ ".gnupg/private-keys-v1.d" ];
  };

  programs.gpg = {
    enable = true;
    settings = {
      trust-model = "tofu+pgp";
    };
    publicKeys = [
      {
        source = fetchKey {
          url = "https://misterio.me/7088C7421873E0DB97FF17C2245CAB70B4C225E9.asc";
          sha256 = "sha256:1bck1r1dfg10za5y9nj7yshr6k69g0lypqp5fjs21d5s68za1rmb";
        };
        trust = 5;
      }
      {
        source = fetchKey {
          url = "https://guip.dev/43827E2886E5C34F38D577538C814D625FBD99D1.asc";
          sha256 = "sha256:1r5lxq4xrqjz8c16l6yh10ablgqrqssgsgshpfaphnfqp6hhvvjd";
        };
        trust = 4;
      }
    ];
  };

}
# vim: filetype=nix
