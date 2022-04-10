{ lib, persistence, ... }: {
  virtualisation.podman.enable = true;

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [
      "/var/lib/containers"
    ];
  };
}
