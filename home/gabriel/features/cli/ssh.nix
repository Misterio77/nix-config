{
  outputs,
  lib,
  config,
  ...
}: let
  nixosConfigs = builtins.attrNames outputs.nixosConfigurations;
  homeConfigs = map (n: lib.last (lib.splitString "@" n)) (builtins.attrNames outputs.homeConfigurations);
  hostnames = lib.unique (homeConfigs ++ nixosConfigs);
in {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      net = {
        host = builtins.concatStringsSep " " hostnames;
        forwardAgent = true;
        remoteForwards = [
          {
            bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
            host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
          }
        ];
      };
      trusted = lib.hm.dag.entryBefore ["net"] {
        host = "m7.rs *.m7.rs *.ts.m7.rs";
        forwardAgent = true;
      };
    };
  };

  home.persistence = {
    "/persist/${config.home.homeDirectory}".files = [
      ".ssh/known_hosts"
    ];
  };
}
