{ lib, persistence, ... }:
{
  services.postgresql.enable = true;

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [
      "/var/lib/postgresql"
    ];
  };
}
