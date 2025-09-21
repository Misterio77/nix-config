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
      user = "prowlarr";
      group = "prowlarr";
      mode = "0700";
    }];
  };

  # Disable DynamicUser
  systemd.services.prowlarr.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = lib.mkForce "prowlarr";
    Group = lib.mkForce "prowlarr";
  };
  users = {
    users.prowlarr = {
      home = "/var/lib/prowlarr";
      group = "prowlarr";
      isSystemUser = true;
    };
    groups.prowlarr = {};
  };
}
