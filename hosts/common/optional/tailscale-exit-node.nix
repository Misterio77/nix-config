{
  imports = [ ../global/tailscale.nix ];
  services.tailscale = {
    useRoutingFeatures = "both";
  };
}
