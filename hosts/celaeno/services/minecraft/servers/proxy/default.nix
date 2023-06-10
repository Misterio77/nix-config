{ pkgs, config, ... }:
let
  servers = config.services.minecraft-servers.servers;
  proxyFlags = memory: "-Xms${memory} -Xmx${memory} -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15";
in
{
  imports = [
    ./geyser.nix
    ./librelogin.nix
    ./luckperms.nix

    ./huskchat.nix
    ./velocitab.nix
    ./vmessage.nix
  ];
  services.minecraft-servers.servers.proxy = {
    enable = true;

    enableReload = true;
    stopCommand = "end";
    extraReload = ''
      echo 'velocity reload' > /run/minecraft-server/proxy.stdin
    '';
    extraPreStop = ''
    '';

    package = pkgs.inputs.nix-minecraft.velocity-server; # Latest build
    jvmOpts = proxyFlags "512M";

    files = {
      "velocity.toml".value = {
        config-version = "2.5";
        bind = "0.0.0.0:25565";
        motd = "Server do Gabs";
        player-info-forwarding-mode = "modern";
        forwarding-secret-file = "";
        forwarding-secret = "@VELOCITY_FORWARDING_SECRET@";
        online-mode = true;
        servers = {
          lobby = "localhost:${toString servers.lobby.serverProperties.server-port}";
          survival = "localhost:${toString servers.survival.serverProperties.server-port}";
          modpack = "localhost:${toString servers.modpack.serverProperties.server-port}";
          limbo = "localhost:${toString servers.limbo.files."settings.yml".value.bind.port}";
          try = [ "lobby" ];
        };
        forced-hosts = {
          "modpack.m7.rs" = [ "modpack" "lobby" ];
          "survival.m7.rs" = [ "survival" "lobby" ];
        };
        query = {
          enabled = true;
          port = 25565;
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
