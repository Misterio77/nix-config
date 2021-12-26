{ pkgs, ... }:
let
  iptables = "${pkgs.iptables}/bin/iptables";
  ip6tables = "${pkgs.iptables}/bin/ip6tables";
in
{
  networking = {
    nat = {
      enable = true;
      externalInterface = "eth0";
      internalInterfaces = [ "wg0" ];
    };
    firewall.allowedUDPPorts = [ 51820 ];
    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          ips = [ "10.100.0.1/24" "fdc9:281f:04d7:9ee9::1/64" ];
          listenPort = 51820;
          privateKeyFile = "/data/etc/wireguard/private.key";
          postSetup = ''
            ${iptables} -A FORWARD -i %i -j ACCEPT
            ${iptables} -t nat -A POSTROUTING -o eth0 -j MASQUERADE
          '';
          postShutdown = ''
            ${iptables} -D FORWARD -i %i -j ACCEPT
            ${iptables} -t nat -D POSTROUTING -o eth0 -j MASQUERADE
          '';
          peers = [
            # Calaeno (phone)
            {
              publicKey = "OpU45rd0BrLPWHrtPtN8U5s4b3RU10B4TiHAN0p842g=";
              allowedIPs = [
                # Wireguard IPs
                "10.100.0.2/32"
                "fdc9:281f:04d7:9ee9::2/128"
                # Multicast IPs
                "224.0.0.251/32"
                "ff02::fb/128"
              ];
            }
            # Pleione (laptop)
            {
              publicKey = "zAkZz0taqMnOpoOUgdBnWcRjaRvRVkv874oiYE4ZxV0=";
              allowedIPs = [
                # Wireguard IPs
                "10.100.0.3/32"
                "fdc9:281f:04d7:9ee9::3/128"
                # Multicast IPs
                "224.0.0.251/32"
                "ff02::fb/128"
              ];
            }
          ];
        };
      };
    };
  };

  # ip forwarding
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
