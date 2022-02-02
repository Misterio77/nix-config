{
  services.flatpak.enable = true;
  environment.persistence."/data" = {
    directories = [
      "/var/lib/flatpak"
    ];
  };
}
