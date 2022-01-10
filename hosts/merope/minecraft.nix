{ pkgs, ... }: {
  services = {
    minecraft-server = {
      enable = true;
      package = pkgs.papermc-experimental;
      eula = true;
      jvmOpts =
        "-Xmx3G -Xms3G -XX:+UnlockExperimentalVMOptions -XX:+UseShenandoahGC -Dlog4j2.formatMsgNoLookups=true";
    };

    mysql = {
      enable = true;
      package = pkgs.mariadb;
      ensureDatabases = [ "minecraft" ];
      ensureUsers = [{
        name = "minecraft";
        ensurePermissions = { "minecraft.*" = "ALL PRIVILEGES"; };
      }];
    };

    nginx.virtualHosts = let location = "http://localhost:8123";
    in {
      "mapa.misterio.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = location;
      };
    };
  };

  networking.firewall = {
    # Minecraft, RCON
    allowedTCPPorts = [ 25565 25575 ];
    # GeyserMC, PlasmoVoice
    allowedUDPPorts = [ 19132 60606 ];
  };

  environment.persistence."/data" = {
    directories = [ "/var/lib/minecraft" "/var/lib/mysql" ];
  };
}
