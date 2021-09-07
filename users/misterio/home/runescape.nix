{ pkgs, ... }: {
  home.packages = with pkgs.nur.repos.kira-bruneau; [ runescape-launcher ];

  home.persistence."/data/games/misterio".directories = [ "Jagex" ];

  # Override .desktop for adding gamemoderun
  # TODO: better way other than retyping the entire file?
  xdg.desktopEntries = {
    runescape-launcher = {
      type = "Application";
      name = "RuneScape";
      genericName = "RuneScape";
      comment = "RuneScape - A Free MMORPG from Jagex Ltd.";
      icon = "runescape";
      terminal = false;
      exec = "gamemoderun runescape-launcher %u";
      categories = [ "Game" ];
      mimeType = [ "xscheme-handler/rs-launch" "x-scheme-handler/rs-launchs" ];
    };
  };
}
