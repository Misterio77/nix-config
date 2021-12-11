{ pkgs, ... }: {
  networking = {
    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          ips = [ "10.100.0.3/24" ];
          listenPort = 51820;
          privateKeyFile = "/data/etc/wireguard/private.key";
          peers = [{
            publicKey = "a3dmQRbDmCeWEUyiUxAIjoI5icfzw8llKv5BHTgCJw8=";
            allowedIPs = [ "192.168.77.0/24" ];
            endpoint = "home.misterio.me:51820";
            dynamicEndpointRefreshSeconds = 25;
            persistentKeepalive = 25;
          }];
        };
      };
    };
  };
}
