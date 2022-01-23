{ config, ... }:
{
  services.navidrome = {
    enable = true;
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
    };
  };
  networking.firewall.allowedTCPPorts = [ config.services.navidrome.settings.Port ];
}
