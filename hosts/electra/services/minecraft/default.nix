{ inputs, pkgs, outputs, config, lib, ... }:
let
  papermc = pkgs.callPackage ./pkgs/papermc.nix { };
  velocity = pkgs.callPackage ./pkgs/velocity.nix { };

  remarshal = "${pkgs.remarshal}/bin/remarshal";
  toJSONFile = expr: builtins.toFile "expr" (builtins.toJSON expr);
  toYAMLFile = expr: pkgs.runCommand "expr.yaml" { } ''
    ${remarshal} -i ${toJSONFile expr} -o $out -if json -of yaml
  '';
  toTOMLFile = expr: pkgs.runCommand "expr.toml" { } ''
    ${remarshal} -i ${toJSONFile expr} -o $out -if json -of toml
  '';
  aikarFlags = memory: "-Xms${memory} -Xmx${memory} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";
  proxyFlags = memory: "-Xms${memory} -Xmx${memory} -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15";
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    servers = {

      proxy = {
        enable = true;
        package = velocity;
        jvmOpts = proxyFlags "512M";
        openFirewall = true;
        files = {
          "velocity.toml" = toTOMLFile {
            config-version = "2.5";
            bind = "0.0.0.0:25565";
            motd = "Server do Misterinho";
            player-info-forwarding-mode = "modern";
            forwarding-secret-file = config.sops.secrets.velocity-forwarding-secret.path;
            online-mode = false;
            servers = {
              lobby = "127.0.0.1:25560";
              try = [ "lobby" ];
            };
            forced-hosts = { };
            query = {
              enabled = true;
              port = 25565;
            };
          };
        };
      };

      lobby = {
        enable = true;
        package = papermc;
        jvmOpts = aikarFlags "1G";
        serverProperties = {
          server-port = 25560;
          online-mode = false;
        };
        files = {
          "config/paper-global.yml" = toYAMLFile {
            proxies.velocity = {
              enabled = true;
              online-mode = false;
              secret-file = config.sops.secrets.velocity-forwarding-secret.path;
            };
          };
        };
      };
    };
  };

  sops.secrets = {
    velocity-forwarding-secret = {
      owner = "minecraft";
      group = "minecraft";
      sopsFile = ../../secrets.yaml;
    };
  };
}
