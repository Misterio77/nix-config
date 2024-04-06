{ pkgs, ... }:
let
  geyserUrl =
    n: v: b:
    "https://download.geysermc.org/v2/projects/${n}/versions/${v}/builds/${b}/downloads/velocity";
in
{
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
