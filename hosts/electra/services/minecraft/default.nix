{ inputs, pkgs, outputs, config, ... }:
let
  papermc = pkgs.callPackage ./pkgs/papermc.nix { };
  velocity = pkgs.callPackage ./pkgs/velocity.nix { };
  toTOMLFile = expr: pkgs.runCommand "expr.toml" {} ''
    ${pkgs.remarshal}/bin/remarshal \
    -i ${builtins.toFile "expr" (builtins.toJSON expr)} \
    -o $out -if json -of toml
  '';
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
        jvmOpts = "-Xms1G -Xmx1G -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15";
        openFirewall = true;
        symlinks = {
          "velocity.toml" = toTOMLFile {
            config-version = "2.5";
            bind = "0.0.0.0:25565";
            motd = "Server do Misterinho";
            player-info-forwarding-mode = "modern";
            forwarding-secret-file = config.sops.secrets.velocity-forwarding-secret.path;
            servers = {
              lobby = "127.0.0.1:25560";
              vanilla = "127.0.0.1:25561";
              try = [ "lobby" ];
            };
            forced-hosts = {};
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
        jvmOpts = "-Xmx2G -Xms1G";
        serverProperties = {
          server-port = 25560;
          online-mode = false;
        };
      };

      vanilla = {
        enable = true;
        package = papermc;
        jvmOpts = "-Xmx2G -Xms1G";
        serverProperties.server-port = 25561;
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
