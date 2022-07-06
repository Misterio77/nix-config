{ hostnames, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "gitlab.com".addressFamily = "inet";
      # Forward gpg-agent
      home = {
        host = "${builtins.concatStringsSep " " hostnames}";
        forwardAgent = true;
        remoteForwards = [{
          bind.address = "/run/user/1000/gnupg/S.gpg-agent";
          host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
        }];
      };
    };
  };
}
