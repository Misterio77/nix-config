{ pkgs, ... }: {
  services.minecraft-servers.servers.survival = {
    enable = true;
    enableReload = true;
    package = pkgs.inputs.nix-minecraft.paperServers.paper-1_19_3;
    jvmOpts = ((import ../../aikar-flags.nix) "2G") + "-Dpaper.disableChannelLimit=true";
    serverProperties = {
      server-port = 25571;
      online-mode = false;
    };
    files = {
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
        server = "survival";
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
        version = "4.8.0";
        url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-VHvFMbiA8clgrlpfCNzqlzs/QSVN60Yt6h63KI3w6ns=";
      };
      "plugins/ViaBackwards.jar" = pkgs.fetchurl rec {
        pname = "ViaBackwards";
        version = "4.8.0";
        url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-JSE71YbivWCqUzNwPVFNgqlhhFkMoIstrn+L/F3qdFM=";
      };
      "plugins/LuckPerms.jar" = let build = "1515"; in pkgs.fetchurl rec {
        pname = "LuckPerms";
        version = "5.4.102";
        url = "https://download.luckperms.net/${build}/bukkit/loader/${pname}-Bukkit-${version}.jar";
        hash = "sha256-rShKJtW6FzPba4yATlsS2JHFtBZrQhZeRrPfv/4w1ZY=";
      };
      "plugins/HidePLayerJoinQuit.jar" = pkgs.fetchurl rec {
        pname = "HidePLayerJoinQuit";
        version = "1.0";
        url = "https://github.com/OskarZyg/${pname}/releases/download/v${version}-full-version/${pname}-${version}-Final.jar";
        hash = "sha256-UjLlZb+lF0Mh3SaijNdwPM7ZdU37CHPBlERLR3LoxSU=";
      };
    };
  };
}
