{ pkgs, lib, ... }: {
  services.minecraft-servers.servers.proxy = {
    symlinks = {
      "plugins/Geyser.jar" = pkgs.fetchurl rec {
        pname = "Geyser";
        version = "1498";
        url = "https://ci.opencollab.dev/job/GeyserMC/job/${pname}/job/master/${version}/artifact/bootstrap/velocity/build/libs/${pname}-Velocity.jar";
        hash = "sha256-5mvh8rB+1xwdDuXj98TR2RLs173RzLR1tHsksfMwAjI=";
      };
      "plugins/Floodgate.jar" = pkgs.fetchurl rec {
        pname = "Floodgate";
        version = "92";
        url = "https://ci.opencollab.dev/job/GeyserMC/job/${pname}/job/master/${version}/artifact/velocity/build/libs/${lib.toLower pname}-velocity.jar";
        hash = "sha256-U2TLrXnSL6RkKDAMV5dTQ80yDF9DVdPJORGoKJzAP0M=";
      };
    };
    files = {
      "plugins/Geyser-Velocity/config.yml".value = {
        server-name = "Server do Gabs";
        passthrough-motd = true;
        passthrough-player-counts = true;
        allow-third-party-capes = true;
        auth-type = "floodgate";
      };
    };
  };
}
