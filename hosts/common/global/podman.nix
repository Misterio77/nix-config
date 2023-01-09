{ lib, ... }: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/containers"
    ];
  };
}
