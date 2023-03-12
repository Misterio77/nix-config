{ pkgs, lib, ... }: let
  proxyFlags = memory: "-Xms${memory} -Xmx${memory} -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15";
in {
  services.minecraft-servers.servers.proxy = {
    enable = true;
    package = pkgs.inputs.nix-minecraft.velocity-server; # Latest build
    jvmOpts = proxyFlags "512M";
    files = {
      "velocity.toml".value = {
        config-version = "2.5";
        bind = "0.0.0.0:25565";
        motd = "Server do Misterinho";
        player-info-forwarding-mode = "modern";
        forwarding-secret-file = "";
        forwarding-secret = "@VELOCITY_FORWARDING_SECRET@";
        online-mode = true;
        servers = {
          survival = "localhost:25561";
          limbo = "localhost:25560";
          try = ["survival" "limbo"];
        };
        forced-hosts = {};
        query = {
          enabled = true;
          port = 25565;
        };
      };
      "lang/messages.properties".value = import ./velocity-messages.nix;
      "plugins/Geyser-Velocity/config.yml".value = {
        server-name = "Server do Misterinho";
        passthrough-motd = true;
        passthrough-player-counts = true;
        allow-third-party-capes = true;
        auth-type = "floodgate";
      };
      "plugins/luckperms/config.yml".value = {
        server = "proxy";
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
      "plugins/librelogin/config.conf".format = pkgs.formats.json { };
      "plugins/librelogin/config.conf".value = {
        allowed-commands-while-unauthorized = [
          "login"
          "register"
          "2fa"
          "2faconfirm"
        ];
        auto-register = true;
        database = {
          database = "minecraft";
          host = "localhost";
          max-life-time = 600000;
          password = "@DATABASE_PASSWORD@";
          port = 3306;
          user = "minecraft";
        };
        debug = false;
        default-crypto-provider = "BCrypt-2A";
        fallback = false;
        kick-on-wrong-password = false;
        limbo = ["limbo"];
        migration = {};
        milliseconds-to-refresh-notification = 10000;
        minimum-password-length = -1;
        new-uuid-creator = "MOJANG";
        pass-through.root = ["survival"];
        ping-servers = true;
        remember-last-server = false;
        revision = 3;
        seconds-to-authorize = -1;
        session-timeout = 604800;
        totp = {
          enabled = true;
          label = "Misterinho";
        };
        use-titles = false;
      };
      "plugins/librelogin/messages.conf".format = pkgs.formats.json { };
      "plugins/librelogin/messages.conf".value = import ./librelogin-messages.nix;
    };
    symlinks = {
      # Declaratively configure initial permission schema
      # Import with /lpv import initial.json.gz
      "plugins/luckperms/initial.json.gz".format = pkgs.formats.gzipJson { };
      "plugins/luckperms/initial.json.gz".value = {
        groups = {
          admin.nodes = [
            {
              type = "permission";
              key = "librelogin.user.*";
              value = true;
            }
            {
              type = "permission";
              key = "velocity.command.*";
              value = true;
            }
          ];
          default.nodes = [];
        };
      };

      "plugins/Geyser.jar" = pkgs.fetchurl rec {
        pname = "Geyser";
        version = "1269";
        url = "https://ci.opencollab.dev/job/GeyserMC/job/${pname}/job/master/${version}/artifact/bootstrap/velocity/build/libs/${pname}-Velocity.jar";
        sha256 = "sha256-SKXX/8D9XKKrLZCNfiB31FoPmwbB/cpthz3Lu6yr7FU=";
      };
      "plugins/Floodgate.jar" = pkgs.fetchurl rec {
        pname = "Floodgate";
        version = "74";
        url = "https://ci.opencollab.dev/job/GeyserMC/job/${pname}/job/master/${version}/artifact/velocity/build/libs/${lib.toLower pname}-velocity.jar";
        sha256 = "sha256-yFVVtyqhtSRt/r+i0uSu9HleDmAp+xwAAdWmV4W8umU=";
      };
      "plugins/CopyChat.jar" = pkgs.fetchurl rec {
        pname = "CopyChat";
        version = "1.0.0";
        url = "https://github.com/voruti/${pname}/releases/download/${version}/CopyChat-${version}.jar";
        sha256 = "sha256-Dk7sG4h/2kN12nzLl++MFDJPXit4CAur8n9VlvNb4yA=";
      };
      "plugins/LibreLogin.jar" = pkgs.fetchurl rec {
        pname = "LibreLogin";
        version = "0.13.4";
        url = "https://github.com/kyngs/${pname}/releases/download/${version}/${pname}.jar";
        sha256 = "sha256-UGlKpX6o1x5FscTYNFjez9CqeUjEeLgSzR9XoYYbh98=";
      };
      "plugins/LuckPerms.jar" = pkgs.fetchurl rec {
        pname = "LuckPerms";
        version = "5.4.58";
        url = "https://download.luckperms.net/1467/velocity/${pname}-Velocity-${version}.jar";
        sha256 = "sha256-6sOnzQWjxRHbhewiMaPfGzq+eZabcX5/btj0XF/1oMY=";
      };
    };
  };
}
