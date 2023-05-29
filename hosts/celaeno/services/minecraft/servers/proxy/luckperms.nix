{ pkgs, ... }: {
  services.minecraft-servers.servers.proxy = {
    symlinks = {
      "plugins/LuckPerms.jar" = let build = "1475"; in pkgs.fetchurl rec {
        pname = "LuckPerms";
        version = "5.4.64";
        url = "https://download.luckperms.net/${build}/velocity/${pname}-Velocity-${version}.jar";
        hash = "sha256-8w9lt7Tuq8sPdLzCoSzE/d56bQjTIv1r/iWyMA4MtLk=";
      };

      # Declaratively configure initial permission schema
      # Import with /lpv import initial.json.gz
      "plugins/luckperms/initial.json.gz".format = pkgs.formats.gzipJson { };
      "plugins/luckperms/initial.json.gz".value = {
        groups = {
          admin.nodes = [
            {
              type = "permission";
              key = "librelogin.user.*";
              value = true;
            }
            {
              type = "permission";
              key = "velocity.command.*";
              value = true;
            }
          ];
          default.nodes = [ ];
        };
      };
    };

    files = {
      "plugins/luckperms/config.yml".value = {
        server = "proxy";
        storage-method = "mysql";
        data = {
          address = "127.0.0.1";
          database = "minecraft";
          username = "minecraft";
          password = "@DATABASE_PASSWORD@";
          table-prefix = "luckperms_";
        };
        messaging-service = "sql";
      };
    };
  };
}
