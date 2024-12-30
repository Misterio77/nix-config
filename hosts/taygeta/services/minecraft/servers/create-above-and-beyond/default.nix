{pkgs, inputs, ...}: let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
  modpack = pkgs.fetchzip {
    url = "https://www.curseforge.com/api/v1/mods/542763/files/3567576/download";
    hash = "sha256-B/fbtYpgGwj+Tcr1gAIpIH60leOrAkzcfIARZQFl5Yk=";
    extension = "zip";
    stripRoot = false;
  };
in {
  services.minecraft-servers.servers.create-ab = {
    enable = true;
    enableReload = true;
    package = pkgs.callPackage ./forge-server.nix {};
    jvmOpts = (import ../../aikar-flags.nix) "8G";
    whitelist = import ../../whitelist.nix;
    serverProperties = {
      server-port = 25575;
      online-mode = false;
      level-type = "biomesoplenty";
      difficulty = "normal";
      max-tick-time = -1;
    };
    operators = import ../../ops.nix;

    # Conflicts with bungeeforge
    extraStartPre = ''
      rm mods/connectivity*.jar
    '';
    files = {
      config = "${modpack}/config";
      defaultconfigs = "${modpack}/defaultconfigs";
      kubejs = "${modpack}/kubejs";
    };
    symlinks = collectFilesAt modpack "mods" // {
      "server-icon.png" = "${modpack}/server-icon.png";
      openloader = "${modpack}/openloader";
      worldshape = "${modpack}/worldshape";
      "mods/bungeeforge-1.16.5.jar" = pkgs.fetchurl rec {
        pname = "bungeeforge";
        version = "1.0.6";
        url = "https://github.com/caunt/BungeeForge/releases/download/v${version}/bungeeforge-1.16.5.jar";
        hash = "sha256-Gtq/b/XqS1WwWA5N0YVJjw6AqJu5qoeNBaFwgjeNpxk=";
      };
    };
  };
}
