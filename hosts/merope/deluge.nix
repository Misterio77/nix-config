{ lib, config, persistence, ... }: {
  services.deluge = {
    enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [ 58846 6881 ];
    allowedUDPPorts = [ 58846 6881 ];
  };

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [ "/var/lib/deluge" ];
  };
}
