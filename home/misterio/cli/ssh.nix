{ hostname, hostnames, lib, ... }:
let
  inherit (builtins) listToAttrs;
  inherit (lib) forEach;

  gpgSocket = {
    atlas = "/run/user/1000/gnupg/d.a4tgapgc5zq8soa5kpqxgtpy";
    merope = "/run/user/1000/gnupg/d.z457sbn83pofmpho4jgb5mea";
    pleione = "/gun/user/1000/gnupg/d.ki7qxawngy45df3o63uz7fep";
  };

  mkMatchBlock = client: server: {
    name = server;
    value = {
      forwardAgent = true;
      remoteForwards = [{
        bind.address = "${gpgSocket.${server}}/S.gpg-agent";
        host.address = "${gpgSocket.${client}}/S.gpg-agent.extra";
      }];
    };
  };
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = listToAttrs (forEach hostnames (mkMatchBlock hostname));
  };
}
