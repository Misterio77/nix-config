{config, lib, pkgs, ...}: {
  services.opencode = {
    enable = true;
    hostname = "0.0.0.0";
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    config.services.opencode.port
  ];
}
