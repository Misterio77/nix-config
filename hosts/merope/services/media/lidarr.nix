{
  services.lidarr = {
    enable = true;
  };

  environment.persistence = {
    "/persist".directories = ["/var/lib/lidarr"];
  };
}
