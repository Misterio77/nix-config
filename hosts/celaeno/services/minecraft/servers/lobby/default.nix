{pkgs, ...}: {
  services.minecraft-servers.servers.lobby = {
    enable = true;
    enableReload = true;
    package = pkgs.inputs.nix-minecraft.paperServers.paper-1_19_3;
    jvmOpts = ((import ../../aikar-flags.nix) "2G") + "-Dpaper.disableChannelLimit=true";
    serverProperties = {
      server-port = 25574;
      online-mode = false;
      allow-nether = false;
      level-type = "flat";
      gamemode = "adventure";
      force-gamemode = true;
      generator-settings = builtins.toJSON {
        layers = [
          {
            block = "air";
            height = "1";
          }
        ];
        biome = "the_void";
      };
      enable-rcon = true;
      "rcon.password" = "@RCON_PASSWORD@";
      "rcon.port" = 24474;
    };
    operators = import ../../ops.nix;
    files = {
      "config/paper-global.yml".value = {
        proxies.bungeecord = {
          online-mode = true;
        };
      };
      "bukkit.yml".value = {
        settings = {
          shutdown-message = "Servidor fechado (provavelmente reiniciando).";
          allow-end = false;
        };
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
        server = "lobby";
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
        version = "5.2.0";
        url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-VINGb0qpYLaH+JF46TkYwnqn+p0G/7xJlXKc4KpVhNY=";
      };
      "plugins/ViaBackwards.jar" = pkgs.fetchurl rec {
        pname = "ViaBackwards";
        version = "5.2.0";
        url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-kOyHZUZddHWpXy8EqXTUj9r+MrFZD8V33jDgtS9OSGM=";
      };
      "plugins/ViaRewind.jar" = pkgs.fetchurl rec {
        pname = "ViaRewind";
        version = "4.0.4";
        url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-wJlG0D+ev22xUvOucpnccSpjCZtDi9a2OesIU/TJkb8=";
      };
      "plugins/LuckPerms.jar" = let
        build = "1568";
      in
        pkgs.fetchurl rec {
          pname = "LuckPerms";
          version = "5.4.151";
          url = "https://download.luckperms.net/${build}/bukkit/loader/${pname}-Bukkit-${version}.jar";
          hash = "sha256-7ZSsWkCMTJUIYw2T2hy9ICgMNCe6BOvt9+w9OgTKeEM=";
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
