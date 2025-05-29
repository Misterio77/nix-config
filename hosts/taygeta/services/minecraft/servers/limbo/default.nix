{pkgs, config, ...}: let
  cfg = config.services.minecraft-servers.servers.limbo;
in {
  services.minecraft-servers.servers.limbo = {
    enable = true;
    serverProperties = {
      server-ip = "127.0.0.1";
      server-port = 25560;
    };

    package = pkgs.callPackage ./nano-limbo-server.nix {};
    jvmOpts = "";

    files."settings.yml".value = {
      bind = {
        ip = cfg.serverProperties.server-ip;
        port = cfg.serverProperties.server-port;
      };
      maxPlayers = -1;
      ping = {
        description = "Limbo";
        version = "1.5";
      };
      dimension = "THE_END";
      playerList = {
        enable = false;
        username = "NanoLimbo";
      };
      headerAndFooter.enable = false;
      gameMode = 3;
      brandName.enable = false;
      joinMessage.enable = false;
      bossBar.enable = false;
      title.enable = false;
      infoForwarding = {
        type = "LEGACY";
      };
      readTimeout = 30000;
      debugLevel = 2;
      netty = {
        useEpoll = true;
        threads = {
          bossGroup = 1;
          workerGroup = 4;
        };
      };
      traffic.enable = false;
    };
  };
}
