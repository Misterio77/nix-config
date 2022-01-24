{ config, ... }: {
  services.deluge = {
    enable = true;
    declarative = true;
    authFile = /data/srv/deluge.key;
    config = {
      download_location = "/srv/torrents/";
      allow_remote = true;
      daemon_port = 58846;
      listen_ports = [ 6881 6889 ];
    };
    openFirewall = true;
  };
  networking.firewall = {
    allowedTCPPorts = [ config.services.deluge.config.daemon_port ];
    allowedUDPPorts = [ config.services.deluge.config.daemon_port ];
  };
}
