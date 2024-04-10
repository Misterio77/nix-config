{pkgs, ...}: let
  geyserUrl = n: v: b: "https://download.geysermc.org/v2/projects/${n}/versions/${v}/builds/${b}/downloads/velocity";
in {
  networking.firewall = {
    allowedUDPPorts = [19132];
    extraCommands = let
      timeSeconds = 60;
      maxHits = 10;
    in
      # Block pesky china botnet
      "iptables -I INPUT -p udp --dport 19132 -m state --state NEW -m recent --update --seconds ${toString timeSeconds} --hitcount ${toString maxHits} -j DROP";
  };

  services.minecraft-servers.servers.proxy = {
    symlinks = {
      "plugins/Geyser.jar" = pkgs.fetchurl rec {
        pname = "geyser";
        version = "2.2.2";
        url = geyserUrl pname version "427";
        hash = "sha256-vGrENEZfOjh8FLYVDyX9/lXwkR+0lAsEafV/F0F+4hk=";
      };
      "plugins/Floodgate.jar" = pkgs.fetchurl rec {
        pname = "floodgate";
        version = "2.2.2";
        url = geyserUrl pname version "90";
        hash = "sha256-v7Gfwl870Vy6Q8PcBETFKknVL5UVEWbGmCiw4MVR7XE=";
      };
    };
    files = {
      "plugins/Geyser-Velocity/config.yml".value = {
        server-name = "Server do Gabs";
        passthrough-motd = true;
        passthrough-player-counts = true;
        allow-third-party-capes = true;
        auth-type = "floodgate";
      };
    };
  };
}
