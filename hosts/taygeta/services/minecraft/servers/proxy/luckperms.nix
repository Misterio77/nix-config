{
  pkgs,
  lib,
  ...
}: {
  services.minecraft-servers.servers.proxy = rec {
    extraStartPost = ''
      echo 'lpv import initial.json.gz' > /run/minecraft/proxy.stdin
    '';
    extraReload = extraStartPost;

    symlinks = {
      "plugins/LuckPerms.jar" = let
        build = "1568";
      in
        pkgs.fetchurl rec {
          pname = "LuckPerms";
          version = "5.4.151";
          url = "https://download.luckperms.net/${build}/velocity/${pname}-Velocity-${version}.jar";
          hash = "sha256-vOT1XvFhUFTwTWajItvKyAmvcgMK0M/bneMaL+stlX4=";
        };
      "plugins/luckperms/initial.json.gz".format = pkgs.formats.gzipJson {};
      "plugins/luckperms/initial.json.gz".value = let
        mkPermissions = lib.mapAttrsToList (key: value: {inherit key value;});
      in {
        groups = {
          owner.nodes = mkPermissions {
            "group.admin" = true;
            "prefix.1000.&5" = true;
            "weight.1000" = true;

            "librelogin.*" = true;
            "luckperms.*" = true;
            "velocity.command.*" = true;
          };
          admin.nodes = mkPermissions {
            "group.default" = true;
            "prefix.900.&6" = true;
            "weight.900" = true;

            "huskchat.command.broadcast" = true;
          };
          default.nodes = mkPermissions {
            "huskchat.command.channel" = true;
            "huskchat.command.msg" = true;
            "huskchat.command.msg.reply" = true;
          };
        };
        users = {
          "3fc76c64-b1b2-4a95-b3cf-0d7d94db2d75" = {
            username = "misterio7x";
            nodes = mkPermissions {"group.owner" = true;};
          };
          "10ffa557-322a-4b6c-9b3e-cdc2792163ae" = {
            username = "kirao";
            nodes = mkPermissions {"group.admin" = true;};
          };
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
