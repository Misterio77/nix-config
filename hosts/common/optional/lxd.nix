{
  virtualisation.lxd = {
    enable = true;
    preseed = {
      networks = [
        {
          name = "lxdbr0";
          type = "bridge";
          config = {
            "ipv4.address" = "10.0.100.1/24";
            "ipv4.nat" = "true";
          };
        }
      ];
      storage_pools = [
        {
          name = "default";
          driver = "dir";
          config.source = "/var/lib/lxd/storage-pools/default";
        }
      ];
      profiles = [
        {
          name = "default";
          config = {
            "security.privileged" = "true";
          };
          devices = {
            eth0 = {
              name = "eth0";
              network = "lxdbr0";
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
              type = "disk";
            };
          };
        }
      ];
    };
  };
  # https://github.com/NixOS/nixpkgs/issues/263359
  networking.firewall.trustedInterfaces = ["lxdbr0"];
}
