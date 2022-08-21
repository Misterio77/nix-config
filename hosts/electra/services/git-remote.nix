{ config, lib, persistence, pkgs, ... }:
{

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [
      "/srv/git"
    ];
  };

  users = {
    users.git = {
      home = "/srv/git";
      createHome = true;
      isSystemUser = true;
      shell = "${pkgs.git}/bin/git-shell";
      group = "git";
      openssh.authorizedKeys.keys = config.users.users.misterio.openssh.authorizedKeys.keys;
    };
    groups.git = { };
  };
}
