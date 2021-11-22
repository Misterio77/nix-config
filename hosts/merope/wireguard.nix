{ pkgs, ... }:
let
  iptables = "${pkgs.iptables}/bin/iptables";
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
          ips = [ "10.100.0.1/24" ];
          listenPort = 51820;
          privateKeyFile = "/data/etc/wireguard/private.key";
          postSetup = ''
            ${iptables} -A FORWARD -i %i -j ACCEPT
            ${iptables} -A FORWARD -o %i -j ACCEPT
            ${iptables} -t nat -A POSTROUTING -o eth0 -j MASQUERADE
          '';
          postShutdown = ''
            ${iptables} -D FORWARD -i %i -j ACCEPT
            ${iptables} -D FORWARD -o %i -j ACCEPT
            ${iptables} -t nat -D POSTROUTING -o eth0 -j MASQUERADE
          '';
          peers = [
            {
              publicKey = "OpU45rd0BrLPWHrtPtN8U5s4b3RU10B4TiHAN0p842g=";
              allowedIPs = [ "10.100.0.2/32" ];
            }
          ];
        };
      };
    };
  };
}
