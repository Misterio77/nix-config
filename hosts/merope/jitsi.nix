{ config, ... }:
{
  services = {
    jitsi-meet = {
      enable = true;
      hostName = "jitsi.misterio.me";
      nginx.enable = true;
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 10000 ];
  };
}
