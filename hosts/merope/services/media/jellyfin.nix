let
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
        locations."/".proxyPass = "http://localhost:${toString port}";
      };
    };
  };
  environment.persistence = {
    "/persist".directories = ["/var/lib/jellyfin"];
  };
}
