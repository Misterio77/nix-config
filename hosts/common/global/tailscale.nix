{ lib, ... }:
{
  services.tailscale.enable = true;
  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ]; # Facilitate firewall punching
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/tailscale" ];
  };
}
