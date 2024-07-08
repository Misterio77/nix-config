{
  config,
  pkgs,
  ...
}: {
  environment.persistence = {
    "/persist".directories = ["/srv/git"];
  };

  services.gitDaemon = {
    enable = true;
    basePath = "/srv/git";
    exportAll = true;
  };
  networking.firewall.allowedTCPPorts = [9418];

  users = {
    users.git = {
      home = "/srv/git";
      createHome = true;
      homeMode = "755";
      isSystemUser = true;
      shell = "${pkgs.bash}/bin/bash";
      group = "git";
      packages = [pkgs.git];
      openssh.authorizedKeys.keys =
        # My key
        config.users.users.gabriel.openssh.authorizedKeys.keys
        ++
        # The key hydra uses to access other hosts
        # This is used to push CI-gated branches to my nix-config
        config.nix.sshServe.keys;
    };
    groups.git = {};
  };
}
