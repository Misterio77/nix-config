{ inputs, pkgs, outputs, config, lib, ... }:
let
  lib' = import ./lib.nix { inherit pkgs; };
  papermc = lib'.mkMCServer rec {
    pname = "papermc";
    version = "1.19.3-367";
    url = "https://api.papermc.io/v2/projects/paper/versions/1.19.3/builds/367/downloads/paper-1.19.3-367.jar";
    sha256 = "sha256-8OhbQFoLsuJJK38a1PEAdwJIZUSEw3l6jTs/5w4EHko=";
  };
  # FIXME: Using sops secrets would be the way to go, but not all configs support a "file" secret
  # Maybe some way to replace secret strings in nix-minecraft managed files?
  velocityForwardingSecret = "PI5rWuj39WTA";
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 19132 ];
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    servers = {

      proxy = {
        enable = true;
        package =
          let
            ver = "3.1.2-SNAPSHOT";
            build = "207";
          in
          lib'.mkMCServer {
            pname = "velocity";
            version = "${ver}-${build}";
            url = "https://api.papermc.io/v2/projects/velocity/versions/${ver}/builds/${build}/downloads/velocity-${ver}-${build}.jar";
            sha256 = "sha256-gjOTQFQTQT2uH3yDyJhR2+dDnnGcwxeToVuarZUaQxU=";
          };
        jvmOpts = lib'.proxyFlags "512M";
        files = {
          "velocity.toml" = lib'.toTOMLFile {
            config-version = "2.5";
            bind = "0.0.0.0:25565";
            motd = "Server do Misterinho";
            player-info-forwarding-mode = "modern";
            forwarding-secret-file = builtins.toFile "secret" velocityForwardingSecret;
            online-mode = true;
            servers = {
              limbo = "localhost:25560";
              survival = "localhost:25561";
              try = [ "survival" "limbo" ];
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
            secret = velocityForwardingSecret;
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
        package = papermc;
        jvmOpts = lib'.aikarFlags "1G";
        serverProperties = {
          server-port = 25561;
          online-mode = false;
        };
        files = {
          "config/paper-global.yml" = lib'.toYAMLFile {
            proxies.velocity = {
              enabled = true;
              online-mode = false;
              secret = velocityForwardingSecret;
            };
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
        };
      };
    };
  };
}
