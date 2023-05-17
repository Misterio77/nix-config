{ lib, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
  };
  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ]; # Facilitate firewall punching
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/tailscale" ];
  };
}
