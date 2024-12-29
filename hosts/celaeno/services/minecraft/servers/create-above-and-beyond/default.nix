{pkgs, ...}: let
  forge = "forge-1.16.5-36.2.8";
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
    extraStartPre = ''
      if ! [ -e "${forge}.jar" ]; then
        ${pkgs.jre8}/bin/java -jar ${forge}-installer.jar --installServer
      fi
    '';
    package = modpack;
    jvmOpts = (import ../../aikar-flags.nix) "8G";

    serverProperties = {
      server-port = 25575;
      online-mode = false;
      level-type = "biomesoplenty";
    };
    operators = import ../../ops.nix;

    files = {
      config = "${modpack}/config";
    };
    symlinks = {
      "${forge}-installer.jar" = "${modpack}/${forge}-installer.jar";
      "server-icon.png" = "${modpack}/server-icon.png";
      defaultconfigs = "${modpack}/defaultconfigs";
      kubejs = "${modpack}/kubejs";
      mods = "${modpack}/mods";
      openloader = "${modpack}/openloader";
      worldshape = "${modpack}/worldshape";
    };
  };
}
