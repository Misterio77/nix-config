{
  virtualisation.podman.enable = true;

  environment.persistence."/data" = {
    directories = [
      "/var/lib/containers"
    ];
  };
}
