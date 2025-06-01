{
  pkgs,
  config,
  ...
}: let
  servers = config.services.minecraft-servers.servers;
  cfg = servers.proxy;
  proxyFlags = memory: "-Xms${memory} -Xmx${memory} -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15";
in {
  imports = [
    ./librelogin.nix
    ./luckperms.nix
    ./fallbackserver.nix
    ./huskchat.nix
    ./velocitab.nix
  ];

  networking.firewall = {
    allowedTCPPorts = [cfg.serverProperties.server-port];
    allowedUDPPorts = [cfg.serverProperties.server-port];
  };

  services.minecraft-servers.servers.proxy = {
    enable = true;

    enableReload = true;
    stopCommand = "end";
    extraReload = ''
      echo 'velocity reload' > /run/minecraft/proxy.stdin
    '';

    serverProperties = {
      server-ip = "0.0.0.0";
      server-port = 25565;
      online-mode = true;
      motd = "Server do Mr. GELOS";
    };

    package = pkgs.inputs.nix-minecraft.velocity-server; # Latest build
    jvmOpts = proxyFlags "1G";

    files = {
      "velocity.toml".value = {
        inherit (cfg.serverProperties) motd online-mode;
        config-version = "2.5";
        bind = "${cfg.serverProperties.server-ip}:${toString cfg.serverProperties.server-port}";
        player-info-forwarding-mode = "legacy";
        servers = let
          mkIp = server: "localhost:${toString server.serverProperties.server-port}";
        in {
          limbo = mkIp servers.limbo;
          auth = mkIp servers.limbo;
          gtnh = mkIp servers.gtnh;
          try = ["limbo"];
        };
        forced-hosts = {
        };
        query = {
          enabled = true;
          port = cfg.serverProperties.server-port;
        };
        advanced = {
          login-ratelimite = 500;
        };
      };
      "lang/messages.properties" = ./messages.properties;
      "plugins/ambassador/Ambassador.toml".value = {
        config-version = "2.1";
        bypass-registry-checks = true;
        enable-kick-reset = true;
        reconnect-message = "&ePor favor, reconecte.";
      };
    };
    symlinks = {
      "plugins/OwoVelocityPlugin.jar" = pkgs.fetchurl rec {
        pname = "OwoVelocityPlugin";
        version = "0.1.2";
        url = "https://github.com/wisp-forest/owo-velocity-plugin/releases/download/${version}/${pname}.jar";
        hash = "sha256-aiAlYdJV2tCxaCMWv9S0Opn29aMGHVyPiJ00ePe1CDw=";
      };
      "plugins/Ambassador-Velocity.jar" = pkgs.fetchurl rec {
        pname = "Ambassador";
        version = "1.4.5";
        url = "https://github.com/adde0109/Ambassador/releases/download/v${version}/Ambassador-Velocity-${version}-all.jar";
        hash = "sha256-fFemScOUhnLL7zWjuqj3OwRqxQnqj/pu4wCIkNNvLBc=";
      };
    };
  };
}
