{ pkgs, ... }:
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/mysql"
    ];
  };
}
