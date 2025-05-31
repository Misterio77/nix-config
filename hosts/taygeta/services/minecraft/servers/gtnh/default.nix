{pkgs, ...}: let
  gtnh = pkgs.callPackage ./gtnh.nix { };
in {
  services.minecraft-servers.servers.gtnh = {
    enable = true;
    package = gtnh;
    jvmOpts = "-Xms6G -Xmx6G -Dfml.readTimeout=180";
    serverProperties = {
      level-type = "rwg";
      difficulty = 3;
    };
    symlinks.mods = "${gtnh}/lib/mods";
    files.config = "${gtnh}/lib/config";
  };
}
