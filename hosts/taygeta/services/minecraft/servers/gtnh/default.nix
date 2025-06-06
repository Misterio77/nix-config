{pkgs, config, ...}: let
  cfg = config.services.minecraft-servers.servers.gtnh;
in {
  networking.firewall = {
    allowedTCPPorts = [cfg.serverProperties.server-port];
    allowedUDPPorts = [cfg.serverProperties.server-port];
  };

  services.minecraft-servers.servers.gtnh = rec {
    enable = true;
    enableReload = true;
    package = pkgs.callPackage ./gtnh.nix { };
    jvmOpts = "-Xms6G -Xmx6G -Dfml.readTimeout=180";
    whitelist = import ../../whitelist.nix;
    serverProperties = {
      level-type = "rwg";
      difficulty = 3;
      spawn-protection = 1;
      server-port = 25565;
      online-mode = true;
      white-list = true;
    };
    files = {
      config = "${package}/lib/config";
      serverutilities = "${package}/lib/serverutilities";
      "serverutilities/serverutilities.cfg" = ./serverutilities.cfg;
      "config/JourneyMapServer/world.cfg" = {
        format = pkgs.formats.json {};
        value = {
          UseWorldID = true;
          SaveInWorldFolder = true;
          cave = {
            PlayerCaveMapping = true;
            OpCaveMapping = true;
          };
          radar = {
            PlayerRadar = true;
            OpRadar = true;
          };
          ConfigVersion = 1.11;
        };
      };
    };
    symlinks = {
      "mods/bungeeforge-1.7.10.jar" = pkgs.fetchurl rec {
        pname = "bungeeforge";
        version = "1.0.6";
        url = "https://github.com/caunt/BungeeForge/releases/download/v${version}/bungeeforge-1.7.10.jar";
        hash = "sha256-Y10ExD0nn1pkjhrgsSq9eiww5+n0J5skoC2EetXCVGM=";
      };
    };
  };
}
