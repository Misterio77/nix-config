{ pkgs, lib, ... }:
let
  modpack = (pkgs.inputs.nix-minecraft.fetchPackwizModpack rec {
    version = "0.2.18";
    url = "https://github.com/Misterio77/Modpack/raw/${version}/pack.toml";
    packHash = "sha256-eafCRPx6bjEOKNmm4FxhAeTKZRgZNnjKxm5U4DEejjc=";
    manifestHash = "sha256:0rrqzamcf7g6pvjqj6ldyn2px3qr3ywg6slnmq7dxfv0kwnxq69i";
  }).addFiles {
    "mods/FabricProxy-Lite.jar" = pkgs.fetchurl rec {
      pname = "FabricProxy-Lite";
      version = "1.1.6";
      url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/v${version}/${pname}-${version}.jar";
      hash = "sha256-U+nXvILXlYdx0vgomVDkKxj0dGCtw60qW22EK4FhAJk=";
    };
    "mods/CrossStitch.jar" = pkgs.fetchurl rec {
      pname = "crossstitch";
      version = "0.1.4";
      url = "https://cdn.modrinth.com/data/YkOyn1Pn/versions/${version}/${pname}-${version}.jar";
      hash = "sha256-36Ir0fT/1XEq63vpAY1Fvg+G9cYdLk4ZKe4YTIEpdGg=";
    };
    "mods/JoinLeaveMessages-Fabric.jar" = pkgs.fetchurl rec {
      pname = "joinleavemessages";
      version = "1.2.1";
      url = "https://github.com/Phelms215/${pname}-fabric/releases/download/${version}/${pname}-${version}.jar";
      hash = "sha256-x2k090WCMAfpXLBRE6Mz/NyISalzoz+a48809ThPsCQ=";
    };
  };

  mcVersion = "${modpack.manifest.versions.minecraft}";
  fabricVersion = "${modpack.manifest.versions.fabric}";
  serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}-${fabricVersion}";
in
{
  services.minecraft-servers.servers.modpack = {
    enable = true;
    enableReload = true;

    package = pkgs.inputs.nix-minecraft.fabricServers.${serverVersion};
    jvmOpts = (import ../../aikar-flags.nix) "6G";
    serverProperties = {
      server-port = 25572;
      online-mode = false;
    };
    files = {
      "config/luckperms/luckperms.conf".format = pkgs.formats.yaml { };
      "config/luckperms/luckperms.conf".value = {
        server = "modpack";
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
      "config/FabricProxy-Lite.toml".value = {
        hackEarlySend = false; # Needed for luckperms
        hackOnlineMode = false;
        secret = "@VELOCITY_FORWARDING_SECRET@";
      };
      "config/origins_server.toml".value = {
        performVersionCheck = false;
      };
      "config/appliedenergistics2/common.json" = "${modpack}/config/appliedenergistics2/common.json";
      "config/bclib/main.json" = "${modpack}/config/bclib/main.json";
      "config/bclib/server.json" = "${modpack}/config/bclib/server.json";
      "config/charm.toml" = "${modpack}/config/charm.toml";
      "config/mostructures-config-v5.json5" = "${modpack}/config/mostructures-config-v5.json5";
    };
    symlinks = {
      "mods" = "${modpack}/mods";
      "global_packs/required_data" = "${modpack}/global_packs/required_data";
      "config/yosbr" = "${modpack}/config/yosbr";
    };
  };
}
