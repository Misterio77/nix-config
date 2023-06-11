{ pkgs, ... }: {
  services.minecraft-servers.servers.proxy = {
    extraReload = ''
      echo 'velocitab reload' > /run/minecraft-server/proxy.stdin
    '';
    symlinks = {
      "plugins/Velocitab.jar" = pkgs.fetchurl rec {
        pname = "Velocitab";
        version = "1.4";
        url = "https://github.com/WiIIiam278/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-nMp1VX3DNQq8dEzl6syJvCkQpt1jcoxQD9u4S3UfVyI=";
      };
    };
    files = {
      "plugins/velocitab/config.yml".value = {
        headers.default = [ "&7FierceLands" ];
        footers.default = [];
        formats.default = "&7[%server%] &r%prefix%%username%";

        server_groups.default = [ ];
        fallback_enabled = true;
        fallback_group = "default";
        only_list_players_in_same_group = false;
        server_display_names = { };

        formatting_type = "MINEDOWN";
        enable_papi_hook = true;
        enable_miniplaceholders_hook = true;
        sort_players = true;
        sort_players_by = [ "ROLE_WEIGHT" "ROLE_NAME" ];
        update_rate = 1000;
      };
    };
  };
}
