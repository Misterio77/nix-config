{ outputs, hostname, persistence, lib, ... }:
let
  notSelf = n: n != hostname;
  hostnames = builtins.filter notSelf (builtins.attrNames outputs.nixosConfigurations);
in
{
  programs.ssh = {
    enable = true;
    matchBlocks.home = {
      host = builtins.concatStringsSep " " (hostnames ++ [
        "misterio.me"
        "*.misterio.me"
        "*.ts.misterio.me"
        "m7.rs"
        "*.m7.rs"
        "*.ts.m7.rs"
      ]);
      forwardAgent = true;
      remoteForwards = [{
        bind.address = ''/run/user/1000/gnupg/S.gpg-agent'';
        host.address = ''/run/user/1000/gnupg/S.gpg-agent.extra'';
      }];
    };
  };

  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio".directories = [ ".ssh" ];
  };
}
