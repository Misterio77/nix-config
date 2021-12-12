{
  virtualisation.docker.enable = true;

  environment.persistence."/data" = {
    directories = [
      "/var/lib/docker"
    ];
  };
}
