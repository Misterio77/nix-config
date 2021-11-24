{ pkgs, features, lib, ... }: {
  home.packages = with pkgs; [
    runelite
    nur.repos.kira-bruneau.runescape-launcher
  ];

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/games/misterio".directories = [ "Jagex" ];
  };

  # Override .desktop for changing OSRS cache dir
  # TODO: better way other than retyping the entire file?
  xdg.desktopEntries = {
    RuneLite = {
      categories = [ "Game" ];
      comment = "Open source Old School RuneScape client";
      exec =
        "env _JAVA_OPTIONS=-Duser.home=/home/misterio/Jagex/ gamemoderun runelite";
      genericName = "Oldschool RuneScape";
      icon = "runescape";
      name = "RuneLite";
      terminal = false;
      type = "Application";
    };
  };

  # Override .desktop for adding gamemoderun
  # TODO: better way other than retyping the entire file?
  xdg.desktopEntries = {
    runescape-launcher = {
      categories = [ "Game" ];
      comment = "RuneScape - A Free MMORPG from Jagex Ltd.";
      exec = "gamemoderun runescape-launcher %u";
      genericName = "RuneScape";
      icon = "runescape";
      name = "RuneScape";
      terminal = false;
      type = "Application";
    };
  };
}
