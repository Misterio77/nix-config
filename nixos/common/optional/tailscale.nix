{ lib, persistence, ... }:
{
  services.tailscale.enable = true;
  networking = {
    search = [ "misterio.me" ];
    firewall.checkReversePath = "loose";
  };

  environment.persistence = lib.mkIf persistence {
    "/persist".directories = [ "/var/lib/tailscale" ];
  };
}
