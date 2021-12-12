{
  services.postgresql.enable = true;

  environment.persistence."/data" = {
    directories = [
      "/var/lib/postgresql"
    ];
  };
}
