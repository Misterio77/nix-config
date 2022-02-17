{ lib, persistence, ... }:
{
  virtualisation.docker.enable = true;

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [
      "/var/lib/docker"
    ];
  };
}
