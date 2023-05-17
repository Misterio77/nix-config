{ pkgs, lib, ... }:
let
  name = "modpack";

  modpack = (pkgs.inputs.nix-minecraft.fetchPackwizModpack rec {
    pname = "modpack";
    version = "0.2.9";
    url = "https://github.com/Misterio77/Modpack/raw/${version}/pack.toml";
    packHash = "sha256-L5RiSktqtSQBDecVfGj1iDaXV+E90zrNEcf4jtsg+wk=";
    manifestHash = "sha256:0cblpbqwb7ikqr2lwc355mq9kymrm5dl8bxkha81r8iqdyw65w5s";
  }).addFiles {
    "mods/FabricProxy-Lite.jar" = pkgs.fetchurl rec {
      pname = "FabricProxy-Lite";
      version = "1.1.6";
      url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/v${version}/${pname}-${version}.jar";
      hash = "sha256-U+nXvILXlYdx0vgomVDkKxj0dGCtw60qW22EK4FhAJk=";
    };
  };

  mcVersion = "${modpack.manifest.versions.minecraft}";
  fabricVersion = "${modpack.manifest.versions.fabric}";
  serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}-${fabricVersion}";
in
{
  services.minecraft-servers.servers.${name} = {
    enable = true;
    package = pkgs.inputs.nix-minecraft.fabricServers.${lib.traceVal serverVersion};
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
        server = name;
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
        hackEarlySend = true; # Needed for luckperms
        hackOnlineMode = true;
        secret = "@VELOCITY_FORWARDING_SECRET@";
      };
      "config/yosbr" = "${modpack}/config/yosbr";
    };
    symlinks = {
      "mods" = "${modpack}/mods";
      "global_packs" = "${modpack}/global_packs";
    };
  };
}
