{
  virtualisation.podman.enable = true;

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/containers"
    ];
  };
}
