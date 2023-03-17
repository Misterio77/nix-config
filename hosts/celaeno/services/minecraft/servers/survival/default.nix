{ pkgs, ... }:
let
  name = "survival";
in
{
  services.minecraft-servers.servers.${name} = {
    enable = true;
    # Latest 1.19.3 build
    package = pkgs.inputs.nix-minecraft.paperServers.paper-1_19_3;
    jvmOpts = (import ../../aikar-flags.nix) "2G";
    serverProperties = {
      server-port = 25571;
      online-mode = false;
    };
    files = {
      "ops.json".value = [
        {
          uuid = "3fc76c64-b1b2-4a95-b3cf-0d7d94db2d75";
          name = "Misterio7x";
          level = 4;
        }
      ];
      "config/paper-global.yml".value = {
        proxies.velocity = {
          enabled = true;
          online-mode = false;
          secret = "@VELOCITY_FORWARDING_SECRET@";
        };
      };
      "bukkit.yml".value = {
        settings.shutdown-message = "Servidor fechado (provavelmente reiniciando).";
      };
      "spigot.yml".value = {
        messages = {
          whitelist = "Você não está na whitelist!";
          unknown-command = "Comando desconhecido.";
          restart = "Servidor reiniciando.";
        };
      };
      "plugins/ViaVersion/config.yml".value = {
        checkforupdates = false;
      };
      "plugins/LuckPerms/config.yml".value = {
        server = name;
        storage-method = "mysql";
        data = {
          address = "127.0.0.1";
          database = "minecraft";
          username = "minecraft";
          password = "@DATABASE_PASSWORD@";
          table-prefix = "luckperms_";
        };
        messaging-service = "sql";
      };
    };
    symlinks = {
      "plugins/ViaVersion.jar" = pkgs.fetchurl rec {
        pname = "ViaVersion";
        version = "4.6.0";
        url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
        sha256 = "sha256-QgGMRrsRTSpgU1bmdv4BZB/aXaknz35V5knzD4382ls=";
      };
      "plugins/ViaBackwards.jar" = pkgs.fetchurl rec {
        pname = "ViaBackwards";
        version = "4.6.0";
        url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
        sha256 = "sha256-u8dFq4CAXpNF/JjONVg45HR3qbZ5eQmnAq2PvIZ7g4Q=";
      };
      "plugins/LuckPerms.jar" = let build = "1475"; in pkgs.fetchurl rec {
        pname = "LuckPerms";
        version = "5.4.64";
        url = "https://download.luckperms.net/${build}/bukkit/loader/${pname}-Bukkit-${version}.jar";
        sha256 = "sha256-t7ZUaZ1jmaLD2X8ZOihdLKAPMR59EZF4KvTZVW0fYMo=";
      };
      "plugins/HidePLayerJoinQuit.jar" = pkgs.fetchurl rec {
        pname = "HidePLayerJoinQuit";
        version = "1.0";
        url = "https://github.com/OskarZyg/${pname}/releases/download/v${version}-full-version/${pname}-${version}-Final.jar";
        sha256 = "sha256-UjLlZb+lF0Mh3SaijNdwPM7ZdU37CHPBlERLR3LoxSU=";
      };
    };
  };
}
