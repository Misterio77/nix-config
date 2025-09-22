{pkgs, lib, ...}: let
  kodi = pkgs.kodi-wayland.withPackages (p: [p.jellyfin p.steam-library p.joystick]);
in {
  users = {
    users.kodi =  {
      home = "/home/kodi";
      isNormalUser = true;
      group = "kodi";
    };
    groups.kodi = {};
  };

  services.cage = {
    enable = true;
    user = "kodi";
    program = lib.getExe' kodi "kodi-standalone";
  };

  environment.persistence = {
    "/persist".directories = [{
      directory = "/home/kodi";
      user = "kodi";
      group = "kodi";
    }];
  };
}
