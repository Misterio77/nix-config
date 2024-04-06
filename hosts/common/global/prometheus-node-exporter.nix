{ config, ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
  };
  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [config.services.prometheus.exporters.node.port];
  };
}
