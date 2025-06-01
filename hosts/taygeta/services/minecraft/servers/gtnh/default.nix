{pkgs, ...}: {
  services.minecraft-servers.servers.gtnh = {
    enable = true;
    package = pkgs.callPackage ./gtnh.nix { };
    jvmOpts = "-Xms6G -Xmx6G -Dfml.readTimeout=180";
    serverProperties = {
      level-type = "rwg";
      difficulty = 3;
    };
  };
}
