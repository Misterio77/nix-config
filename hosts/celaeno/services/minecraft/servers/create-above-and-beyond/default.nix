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
    serverProperties = {
      server-port = 25575;
      online-mode = false;
      level-type = "biomesoplenty";
    };
    operators = import ../../ops.nix;

    files = {
      config = "${modpack}/config";
      defaultconfigs = "${modpack}/defaultconfigs";
    };
    symlinks = collectFilesAt modpack "mods" // {
      "server-icon.png" = "${modpack}/server-icon.png";
      kubejs = "${modpack}/kubejs";
      openloader = "${modpack}/openloader";
      worldshape = "${modpack}/worldshape";
    };
  };
}
