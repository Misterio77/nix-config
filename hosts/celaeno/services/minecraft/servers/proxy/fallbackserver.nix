{ pkgs, ... }: {
  services.minecraft-servers.servers.proxy = {
    extraReload = ''
      echo 'fs reload' > /run/minecraft-server/proxy.stdin
    '';
    symlinks."plugins/FallBackServer.jar" = pkgs.fetchurl rec {
      pname = "FallBackServer";
      version = "3.1.2";
      url =
        "https://github.com/sasi2006166/Fallback-Server/releases/download/${version}/${pname}Velocity-${version}.jar";
      hash = "sha256-T5sJewNcimmZuWEndfLZUk+dbsJZ4qrfseqvVYwZVdg=";
    };
    files = {
      "plugins/fallbackservervelocity/config.yml".value = {
        settings = {
          blacklisted_words = [ "ban" ];
          check_updates = false;
          command_tab_complete = true;
          command_without_permission = true;
          disabled_servers = false;
          disabled_servers_list = { };
          fallback_list = [ "lobby" "limbo" ];
          lobby_command = true;
          lobby_command_aliases = [ "hub" "lobby" ];
          server_blacklist = false;
          server_blacklist_list = [ ];
          stats = true;
          task_period = 5;
        };
        sub_commands = {
          admin.permission = "fallback.admin";
          reload.permission = "fallback.admin.reload";
          add.enabled = false;
          remove.enabled = false;
          set.enabled = false;
          status.enabled = false;
        };
      };
    };
  };
}
