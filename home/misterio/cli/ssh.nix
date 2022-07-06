{ hostname, hostnames, lib, ... }:
let
  inherit (builtins) concatStringsSep;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      home = {
        host = concatStringsSep " " hostnames;
        forwardAgent = true;
        remoteForwards = [{
          bind.address = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent";
          host.address = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.extra";
        }];
      };
    };
  };
}
