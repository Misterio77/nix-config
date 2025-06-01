{pkgs, ...}: {
  services.minecraft-servers.servers.gtnh = rec {
    enable = true;
    package = pkgs.callPackage ./gtnh.nix { };
    jvmOpts = "-Xms6G -Xmx6G -Dfml.readTimeout=180";
    whitelist = import ../../whitelist.nix;
    serverProperties = {
      level-type = "rwg";
      difficulty = 3;
      spawn-protection = 1;
      server-port = 5001;
      online-mode = false;
    };
    files = {
      config = "${package}/lib/config";
      serverutilities = "${package}/lib/serverutilities";
    };
    symlinks = {
      "mods/bungeeforge-1.7.10.jar" = pkgs.fetchurl rec {
        pname = "bungeeforge";
        version = "1.0.6";
        url = "https://github.com/caunt/BungeeForge/releases/download/v${version}/bungeeforge-1.7.10.jar";
        hash = "sha256-Y10ExD0nn1pkjhrgsSq9eiww5+n0J5skoC2EetXCVGM=";
      };
    };
  };
}
