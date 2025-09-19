{
  config,
  pkgs,
  ...
}: {
  environment.persistence = {
    "/persist".directories = [{
      directory = "/srv/git";
      user = config.users.users.git.name;
      group = config.users.users.git.group;
      mode = "0755";
    }];
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
      openssh.authorizedKeys.keys = config.users.users.gabriel.openssh.authorizedKeys.keys;
    };
    groups.git = {};
  };
}
