{ pkgs, lib, ... }:
let
  modpack = pkgs.inputs.nix-minecraft.fetchPackwizModpack rec {
    version = "5864ae6";
    url = "https://github.com/Misterio77/Modpack/raw/${version}/pack.toml";
    packHash = "sha256-7sC/hPAMxA8vn5pwh6lQ5lS4YACZkb7+DjdR0xAqr+4=";
  };

  # Get a given path's (usually a modpack) files at a specific subdirectory
  # (e.g. "config"), and return them in the format expected by the
  # files/symlinks module options.
  collectFilesAt = let
    mapListToAttrs = fn: fv: list:
      lib.listToAttrs (map (x: lib.nameValuePair (fn x) (fv x)) list);
  in path: prefix:
    mapListToAttrs
    (x: builtins.unsafeDiscardStringContext (lib.removePrefix "${path}/" x))
    (lib.id) (lib.filesystem.listFilesRecursive "${path}/${prefix}");

  mcVersion = modpack.manifest.versions.minecraft;
  fabricVersion = modpack.manifest.versions.fabric;
  serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}-${fabricVersion}";
in
{
  services.minecraft-servers.servers.modpack = {
    enable = true;
    enableReload = true;
    extraPostStop = ''
      rm mods global_packs config -rf
    '';

    package = pkgs.inputs.nix-minecraft.fabricServers.${serverVersion};
    jvmOpts = (import ../../aikar-flags.nix) "6G";
    whitelist = import ../../whitelist.nix;
    serverProperties = {
      server-port = 25572;
      online-mode = false;
    };

    symlinks = collectFilesAt modpack "mods" // collectFilesAt modpack "global_packs" // {
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
      "mods/LuckPerms.jar" = pkgs.fetchurl rec {
        pname = "LuckPerms";
        version = "5.4.25";
        url = "https://mediafilez.forgecdn.net/files/3807/225/${pname}-Fabric-${version}.jar";
        hash = "sha256-hXlzmXcMTkhuAj1UmQMI+JasDv5o/tJbVqzZ9ylQRsU=";
      };
    };

    files = collectFilesAt modpack "config" // {
      "config/luckperms/luckperms.conf".format = pkgs.formats.json { };
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
        hackEarlySend = true; # Needed for luckperms
        hackOnlineMode = false;
        secret = "@VELOCITY_FORWARDING_SECRET@";
      };
      "config/origins_server.toml".value = {
        performVersionCheck = false;
      };
    };
  };
}
