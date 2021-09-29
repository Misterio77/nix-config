{ pkgs, ... }: {
  services = {
    minecraft-server = {
      enable = true;
      package = pkgs.papermc;
      declarative = true;
      eula = true;
      jvmOpts =
        "-Xmx3G -Xms3G -XX:+UnlockExperimentalVMOptions -XX:+UseShenandoahGC";
      openFirewall = true;
      serverProperties = {
        motd = "Teste teste";
        enable-rcon = true;
        "rcon.password" = "1609";
      };
    };
  };
  environment.persistence."/data" = {
    directories = [ "/var/lib/minecraft" ];
  };
}
