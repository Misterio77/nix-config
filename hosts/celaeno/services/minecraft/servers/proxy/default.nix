{
  pkgs,
  config,
  ...
}: let
  servers = config.services.minecraft-servers.servers;
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
    allowedTCPPorts = [25565];
    allowedUDPPorts = [25565];
  };

  services.minecraft-servers.servers.proxy = {
    enable = true;

    enableReload = true;
    stopCommand = "end";
    extraReload = ''
      echo 'velocity reload' > /run/minecraft/proxy.stdin
    '';

    package = pkgs.inputs.nix-minecraft.velocity-server; # Latest build
    jvmOpts = proxyFlags "1G";

    files = {
      "velocity.toml".value = {
        config-version = "2.5";
        bind = "0.0.0.0:25565";
        motd = "Server do Mr. GELOS";
        player-info-forwarding-mode = "legacy";
        online-mode = true;
        servers = {
          lobby = "localhost:${toString servers.lobby.serverProperties.server-port}";
          limbo = "localhost:${toString servers.limbo.files."settings.yml".value.bind.port}";
          try = ["lobby"];
        };
        forced-hosts = {};
        query = {
          enabled = true;
          port = 25565;
        };
        advanced = {
          login-ratelimite = 500;
        };
      };
      "lang/messages.properties" = ./messages.properties;
    };
    symlinks = {
      "plugins/OwoVelocityPlugin.jar" = pkgs.fetchurl rec {
        pname = "OwoVelocityPlugin";
        version = "0.1.2";
        url = "https://github.com/wisp-forest/owo-velocity-plugin/releases/download/${version}/${pname}.jar";
        hash = "sha256-aiAlYdJV2tCxaCMWv9S0Opn29aMGHVyPiJ00ePe1CDw=";
      };
    };
  };
}
