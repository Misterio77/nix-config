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
    package = let
      version = "1.16.5-36.2.34";
      installer = pkgs.fetchurl {
        pname = "forge-installer";
        inherit version;
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/${version}/forge-${version}-installer.jar";
      };
      java = "${pkgs.jre8}/bin/java";
    in pkgs.writeShellScriptBin "server" ''
      ${java} -jar ${installer} --installServer
      exec ${java} $@ -jar forge-${version}.jar nogui
    '';
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
    symlinks = collectFilesAt modpack "mods" // {
      "server-icon.png" = "${modpack}/server-icon.png";
      defaultconfigs = "${modpack}/defaultconfigs";
      kubejs = "${modpack}/kubejs";
      openloader = "${modpack}/openloader";
      worldshape = "${modpack}/worldshape";
    };
  };
}
