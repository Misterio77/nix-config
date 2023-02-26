{ inputs, pkgs, outputs, config, lib, ... }:
let
  lib' = pkgs.callPackage ./lib.nix { };
  minecraftPkgs = inputs.nix-minecraft.packages.${pkgs.system};
in
{
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
    ../../../common/optional/mysql.nix
  ];

  sops.secrets.minecraft-secrets = {
    owner = "minecraft";
    group = "minecraft";
    mode = "0440";
    # VELOCITY_FORWARDING_SECRET, DATABASE_PASSWORD
    sopsFile = ../../secrets.yaml;
  };

  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 19132 ];
  };

  services.mysql = {
    ensureDatabases = [ "minecraft" ];
    ensureUsers = [{
      name = "minecraft";
      ensurePermissions = { "minecraft.*" = "ALL PRIVILEGES"; };
    }];
  };
  # Set minecrafts' password (the plugins don't play well with socket auth)
  users.users.mysql.extraGroups = [ "minecraft" ]; # Get access to the secret
  systemd.services.mysql.postStart = lib.mkAfter ''
    source ${config.sops.secrets.minecraft-secrets.path}
    ${config.services.mysql.package}/bin/mysql <<EOF
      ALTER USER 'minecraft'@'localhost'
        IDENTIFIED VIA unix_socket OR mysql_native_password
        USING PASSWORD('$DATABASE_PASSWORD');
    EOF
  '';

  services.minecraft-servers = {
    enable = true;
    eula = true;
    environmentFile = config.sops.secrets.minecraft-secrets.path;
    servers = {
      proxy = {
        enable = true;
        package = minecraftPkgs.velocity-server; # Latest build
        jvmOpts = lib'.proxyFlags "512M";
        files = {
          "velocity.toml" = lib'.toTOMLFile {
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
              try = [ "survival" "limbo" ];
            };
            forced-hosts = { };
            query = {
              enabled = true;
              port = 25565;
            };
          };
          "lang/messages.properties" = lib'.toPropsFile (import ./cfgs/velocity-messages.nix);
          "plugins/Geyser-Velocity/config.yml" = lib'.toYAMLFile {
            server-name = "Server do Misterinho";
            passthrough-motd = true;
            passthrough-player-counts = true;
            allow-third-party-capes = true;
            auth-type = "floodgate";
          };
          "plugins/luckperms/config.yml" = lib'.toYAMLFile {
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
          "plugins/librelogin/config.conf" = lib'.toJSONFile {
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
            fallback = false; # TODO
            kick-on-wrong-password = false;
            limbo = [ "limbo" ];
            migration = { };
            milliseconds-to-refresh-notification = 10000;
            minimum-password-length = -1;
            new-uuid-creator = "MOJANG";
            pass-through.root = [ "survival" ];
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
          "plugins/librelogin/messages.conf" = lib'.toJSONFile (import ./cfgs/librepremium-messages.nix);
        };
        symlinks = {
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
          # Declaratively configure initial permission schema
          # Import with /lpv import initial.json.gz
          "plugins/luckperms/initial.json.gz" = lib'.gzipFile (lib'.toJSONFile {
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
              default.nodes = [ ];
            };
          });
        };
      };

      limbo = {
        enable = true;
        package = lib'.mkMCServer rec {
          pname = "nano-limbo";
          version = "1.5";
          url = "https://github.com/Nan1t/NanoLimbo/releases/download/v${version}/NanoLimbo-${version}-all.jar";
          sha256 = "sha256-0zPQNfUEgK0zIdLEUjTGw2N+Nbe8byZfqrkPYBR888Q=";
        };
        jvmOpts = "";
        files."settings.yml" = lib'.toYAMLFile {
          bind.port = 25560;
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
          gameMode = 0;
          brandName.enable = false;
          joinMessage.enable = false;
          bossBar.enable = false;
          title.enable = false;
          infoForwarding = {
            type = "MODERN";
            secret = "@VELOCITY_FORWARDING_SECRET@";
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
        };
      };

      survival = {
        enable = true;
        package = minecraftPkgs.paperServers.paper-1_19_3; # Latest 1.19.3 build
        jvmOpts = lib'.aikarFlags "1G";
        serverProperties = {
          server-port = 25561;
          online-mode = false;
        };
        files = {
          "ops.json" = lib'.toJSONFile [{
            uuid = "3fc76c64-b1b2-4a95-b3cf-0d7d94db2d75";
            name = "Misterio7x";
            level = 4;
          }];
          "config/paper-global.yml" = lib'.toYAMLFile {
            proxies.velocity = {
              enabled = true;
              online-mode = false;
              secret = "@VELOCITY_FORWARDING_SECRET@";
            };
          };
          "bukkit.yml" = lib'.toYAMLFile {
            settings.shutdown-message = "Servidor fechado (provavelmente reiniciando).";
          };
          "spigot.yml" = lib'.toYAMLFile {
            messages = {
              whitelist = "Você não está na whitelist!";
              unknown-command = "Comando desconhecido.";
              restart = "Servidor reiniciando.";
            };
          };
          "plugins/ViaVersion/config.yml" = lib'.toYAMLFile {
            checkforupdates = false;
          };
          "plugins/LuckPerms/config.yml" = lib'.toYAMLFile {
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
            version = "4.5.1";
            url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
            sha256 = "sha256-hMxl5QyMxNL/vx58Jz0tJ8E/SlJ3w7sIvm8Dc70GBXQ=";
          };
          "plugins/ViaBackwards.jar" = pkgs.fetchurl rec {
            pname = "ViaBackwards";
            version = "4.5.1";
            url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
            sha256 = "sha256-wugRc0J2+oche6pI0n97+SabTOmGGDvamBItbl1neuU=";
          };
          "plugins/LuckPerms.jar" = pkgs.fetchurl rec {
            pname = "LuckPerms";
            version = "5.4.58";
            url = "https://download.luckperms.net/1467/bukkit/loader/${pname}-Bukkit-${version}.jar";
            sha256 = "sha256-roi16xTu+04ofFccuSLwFl/UqfvG0flHDq0R9/20oIM=";
          };
          "plugins/HidePLayerJoinQuit.jar" = pkgs.fetchurl rec {
            pname = "HidePLayerJoinQuit";
            version = "1.0";
            url = "https://github.com/OskarZyg/${pname}/releases/download/v${version}-full-version/${pname}-${version}-Final.jar";
            sha256 = "sha256-UjLlZb+lF0Mh3SaijNdwPM7ZdU37CHPBlERLR3LoxSU=";
          };
        };
      };
    };
  };
}
