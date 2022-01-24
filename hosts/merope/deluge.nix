{ config, ... }: {
  services.deluge = {
    enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [ 58846 6881 ];
    allowedUDPPorts = [ 58846 6881 ];
  };

  environment.persistence."/data" = {
    directories = [ "/var/lib/deluge" ];
  };
}
