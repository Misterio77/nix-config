{ config, ... }: {
  services = {
    nginx.virtualHosts = {
      "files.misterio.me" = {
        default = true;
        forceSSL = true;
        enableACME = true;
        locations."/".root = "/media/files";
      };
    };
  };
}
