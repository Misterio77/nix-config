{
  services.tailscale.enable = true;
  networking = {
    nameservers = [
      "100.100.100.100"
      "9.9.9.9"
    ];
    search = [ "example.com.beta.tailscale.net" ];
    firewall.checkReversePath = "loose";
  };
}
