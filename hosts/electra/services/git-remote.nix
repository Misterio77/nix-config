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

  users = {
    users.git = {
      home = "/srv/git";
      createHome = true;
      homeMode = "755";
      isSystemUser = true;
      shell = "${pkgs.git}/bin/git-shell";
      group = "git";
      packages = [ pkgs.git ];
      openssh.authorizedKeys.keys = config.users.users.misterio.openssh.authorizedKeys.keys;
    };
    groups.git = { };
  };
}
