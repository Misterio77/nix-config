{ pkgs, lib, ... }: {
  services.minecraft-servers.servers.proxy = {
    symlinks = {
      "plugins/Geyser.jar" = pkgs.fetchurl rec {
        pname = "Geyser";
        version = "1321";
        url = "https://ci.opencollab.dev/job/GeyserMC/job/${pname}/job/master/${version}/artifact/bootstrap/velocity/build/libs/${pname}-Velocity.jar";
        hash = "sha256-+5IhCqir+fb7STaBqjCbGelH4fnrKLchFAXU2eYORnE=";
      };
      "plugins/Floodgate.jar" = pkgs.fetchurl rec {
        pname = "Floodgate";
        version = "77";
        url = "https://ci.opencollab.dev/job/GeyserMC/job/${pname}/job/master/${version}/artifact/velocity/build/libs/${lib.toLower pname}-velocity.jar";
        hash = "sha256-i5NH115qGu8ubRbPZvMIETtKkS1CfSq6mibdSB8lKA8=";
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
