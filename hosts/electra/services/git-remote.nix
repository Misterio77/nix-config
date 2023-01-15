{ config, lib, pkgs, ... }:
{

  environment.persistence = {
    "/persist".directories = [
      "/srv/git"
    ];
  };

  services.gitDaemon = {
    enable = true;
    basePath = "/srv/git";
    exportAll = true;
  };
  networking.firewall.allowedTCPPorts = [ 9418 ];

  users = {
    users.git = {
      home = "/srv/git";
      createHome = true;
      homeMode = "755";
      isSystemUser = true;
      shell = "${pkgs.bash}/bin/bash";
      group = "git";
      packages = [ pkgs.git ];
      openssh.authorizedKeys.keys =
        config.users.users.misterio.openssh.authorizedKeys.keys;
    };
    groups.git = { };
  };
}
