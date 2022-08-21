{ outputs, hostname, persistence, lib, ... }:
let
  notSelf = n: n != hostname;
  hosts = builtins.filter notSelf (builtins.attrNames outputs.nixosConfigurations);
  hostnames = hosts
    ++ (map (h: "${h}.misterio.me") hosts)
    ++ (map (h: "${h}.fontes.dev.br") hosts)
    ++ (map (h: "${h}.ts.fontes.dev.br") hosts);
in
{
  programs.ssh = {
    enable = true;
    matchBlocks.home = {
      host = builtins.concatStringsSep " " hostnames;
      forwardAgent = true;
      remoteForwards = [{
        bind.address = ''/run/user/1000/gnupg/S.gpg-agent'';
        host.address = ''/run/user/1000/gnupg/S.gpg-agent.extra'';
      }];
    };
  };

  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio/.ssh".files = [ "known_hosts" ];
  };
}
