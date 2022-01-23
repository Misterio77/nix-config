{ config, ... }:
{
  services = {
    navidrome = {
      enable = true;
      settings = {
        Address = "0.0.0.0";
        Port = 4533;
      };
    };

    nginx.virtualHosts =
      let
        location = "http://localhost:${toString config.services.navidrome.settings.Port}";
      in
      {
        "music.misterio.me" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = location;
        };
      };
  };
}
