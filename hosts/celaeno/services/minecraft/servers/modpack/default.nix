{ pkgs, lib, ... }:
let
  modpack = (pkgs.inputs.nix-minecraft.fetchPackwizModpack rec {
    version = "0.2.16";
    url = "https://github.com/Misterio77/Modpack/raw/${version}/pack.toml";
    packHash = "sha256-av8JtUweZkcqIQ/o100L1VAOeNNYNbtJi8Pg5YqVdO4=";
    manifestHash = "sha256:0qqr84pn93yr8pxbk50zr79hldxpgvrxdk3q17cnc9rhkkxpsvhi";
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
  };

  mcVersion = "${modpack.manifest.versions.minecraft}";
  fabricVersion = "${modpack.manifest.versions.fabric}";
  serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}-${fabricVersion}";
in
{
  services.minecraft-servers.servers.modpack = {
    enable = true;
    package = pkgs.inputs.nix-minecraft.fabricServers.${serverVersion};
    jvmOpts = (import ../../aikar-flags.nix) "4G";
    serverProperties = {
      server-port = 25572;
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
      "config/bclib/main.json" = "${modpack}/config/yosbr/config/bclib/main.json";
      "config/bclib/server.json" = "${modpack}/config/yosbr/config/bclib/server.json";
      "config/charm.toml" = "${modpack}/config/yosbr/config/charm.toml";
      "config/mostructures-config-v5.json5" = "${modpack}/config/yosbr/config/mostructures-config-v5.json5";
    };
    symlinks = {
      "mods" = "${modpack}/mods";
      "global_packs/required_data" = "${modpack}/global_packs/required_data";
      "config/yosbr" = "${modpack}/config/yosbr";
    };
  };
}
