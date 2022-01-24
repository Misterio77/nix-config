{ config, ... }: {
  services.deluge = {
    enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [ 58846 ];
    allowedUDPPorts = [ 58846 ];
  };

  environment.persistence."/data" = {
    directories = [ "/var/lib/deluge" ];
  };
}
