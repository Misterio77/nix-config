{ pkgs, ... }: let
  geyserUrl = n: v: b: "https://download.geysermc.org/v2/projects/${n}/versions/${v}/builds/${b}/downloads/velocity";
in {
  services.minecraft-servers.servers.proxy = {
    symlinks = {
      "plugins/Geyser.jar" = pkgs.fetchurl rec {
        pname = "geyser";
        version = "2.2.0";
        url = geyserUrl pname version "408";
        hash = "sha256-aFxd2OzE0daWSEiWP/+4LeLoJz0VXSG2E+zmM9XHPT4=";
      };
      "plugins/Floodgate.jar" =  pkgs.fetchurl rec {
        pname = "floodgate";
        version = "2.2.2";
        url = geyserUrl pname version "85";
        hash = "sha256-Mw0bsoj2zCwqpuuY/cpM1Krcue0XPeybmF6/UA/udWk=";
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
