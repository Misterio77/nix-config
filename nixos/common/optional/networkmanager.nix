{ persistence, lib, ... }: {
  networking.networkmanager.enable = true;

  environment.persistence = lib.mkIf persistence {
    "/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections"
      ];
    };
  };
}
