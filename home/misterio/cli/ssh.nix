{ outputs, ... }:
let
  inherit (builtins) attrNames concatStringsSep;
  hostnames = attrNames outputs.nixosConfigurations;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      home = {
        host = concatStringsSep " " hostnames;
        forwardAgent = true;
        remoteForwards = [{
          bind.address = ''/run/user/1000/gnupg/S.gpg-agent'';
          host.address = ''/run/user/1000/gnupg/S.gpg-agent.extra'';
        }];
      };
    };
  };
}
