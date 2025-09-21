{config, lib, ...}: {
  services.prowlarr = {
    enable = true;
    settings = {
      server.port = 8685;
    };
  };

  environment.persistence = {
    "/persist".directories = [{
      directory = "/var/lib/prowlarr";
    }];
  };

  # Disable DynamicUser
  systemd.services.prowlarr.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = lib.mkForce "prowlarr";
    Group = lib.mkForce "prowlarr";
  };
  users.users.prowlarr = {
    home = "/var/lib/prowlarr";
    group = "prowlarr";
    isSystemUser = true;
  };
}
