{config, ...}: let
  # https://jellyfin.org/docs/general/post-install/networking/
  # TODO: https://github.com/Sveske-Juice/declarative-jellyfin
  port = 8096;
in {
  services = {
    jellyfin = {
      enable = true;
    };
    nginx.virtualHosts = {
      "media.m7.rs" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString port}";
          proxyWebsockets = true;
        };
      };
      "music.m7.rs" = {
        forceSSL = true;
        enableACME = true;
        locations."/".return = "302 https://media.m7.rs/web/#/music.html";
      };
      "music.misterio.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/".return = "302 https://media.m7.rs/web/#/music.html";
      };
    };
  };
  environment.persistence = {
    "/persist".directories = [
      {
        directory = "/var/lib/jellyfin";
        user = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
        mode = "0700";
      }
    ];
  };
}
