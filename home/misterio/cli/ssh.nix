{ outputs, hostname, persistence, lib, ... }:
let
  notSelf = n: n != hostname;
  hostnames = builtins.filter notSelf (builtins.attrNames outputs.nixosConfigurations);
in
{
  programs.ssh = {
    enable = true;
    matchBlocks.net = {
      host = builtins.concatStringsSep " " hostnames;
      forwardAgent = true;
      remoteForwards = [{
        bind.address = ''/%d/.gnupg/sockets/S.gpg-agent'';
        host.address = ''/%d/.gnupg/sockets/S.gpg-agent.extra'';
      }];
    };
  };

  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio".directories = [ ".ssh" ];
  };
}
