{ lib, persistence, ... }: {
  services.flatpak.enable = true;

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [
      "/var/lib/flatpak"
    ];
  };
}
