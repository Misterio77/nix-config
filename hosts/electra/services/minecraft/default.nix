{ inputs, pkgs, outputs, config, lib, ... }:
let
  lib' = pkgs.callPackage ./lib.nix { };
  minecraftPkgs = inputs.nix-minecraft.packages.${pkgs.system};
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  sops.secrets = {
    # VELOCITY_FORWARDING_SECRET=...
    # DATABASE_PASSWORD=...
    minecraft-secrets = {
      owner = "minecraft";
      group = "minecraft";
      sopsFile = ../../secrets.yaml;
    };
    # CREATE USER IF NOT EXISTS 'minecraft'@'localhost';
    # ALTER USER 'minecraft'@'localhost' IDENTIFIED VIA unix_socket OR mysql_native_password USING PASSWORD(...);
    set-minecraft-sql-password = {
      owner = "mysql";
      group = "mysql";
      sopsFile = ../../secrets.yaml;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 19132 ];
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "minecraft" ];
    ensureUsers = [{
      name = "minecraft";
      ensurePermissions = { "minecraft.*" = "ALL PRIVILEGES"; };
    }];
    initialScript = lib.mkAfter config.sops.secrets.set-minecraft-sql-password.path;
  };

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
              try = [ "survival" ];
            };
            forced-hosts = { };
            query = {
              enabled = true;
              port = 25565;
            };
          };
          "plugins/Geyser-Velocity/config.yml" = lib'.toYAMLFile {
            server-name = "Server do Misterinho";
            passthrough-motd = true;
            passthrough-player-counts = true;
            allow-third-party-capes = true;
            auth-type = "floodgate";
          };
          "plugins/limboapi/config.yml" = lib'.toYAMLFile {
            prefix = "Limbo";
            main.check-for-updates = false;
          };
          "plugins/limboauth/config.yml" = lib'.toYAMLFile {
            prefix = "Auth";
            main = {
              auth-time = 0;
              enable-bossbar = false;
              online-mode-need-auth = false;
              floodgate-need-auth = false;
              save-premium-accounts = false;
              enable-totp = false;
              register-need-repeat-password = false;
              strings = import ./cfgs/limboauth-strings.nix;
            };
            database.storage-type = "sqlite";
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
          "plugins/LimboAPI.jar" = pkgs.fetchurl rec {
            pname = "LimboAPI";
            version = "1.0.8";
            url = "https://github.com/Elytrium/${pname}/releases/download/${version}/${pname}-plugin-${version}-jdk17.jar";
            sha256 = "sha256-qGBBHSEGdUXLDQkCBKn5N28/9Zlazu8/fYrAIvlb0EA=";
          };
          "plugins/LimboAuth.jar" = pkgs.fetchurl rec {
            pname = "LimboAuth";
            version = "1.0.8";
            url = "https://github.com/Elytrium/${pname}/releases/download/${version}/${pname}-${version}-jdk17.jar";
            sha256 = "sha256-S1u7QHF0n6EhGq++VF7BlbaJ4Y8xpQWR2BuGQBeW+r8=";
          };
          "plugins/HuskChat.jar" = pkgs.fetchurl rec {
            pname = "HuskChat";
            version = "2.3";
            url = "https://github.com/WiIIiam278/${pname}/releases/download/${version}/${pname}-${version}.jar";
            sha256 = "sha256-gNgL1rYxpDGJmmBURwYe8t3rTzOOiII3kmmZHd8mFHY=";
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
              admin.nodes = [{
                type = "prefix";
                key = "prefix.0.ADM";
                value = true;
              }];
              default.nodes = [ ];
            };
          });
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
        };
      };
    };
  };
}
