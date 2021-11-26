{ pkgs, lib, features, hostname, ... }: {
  home.packages = [ pkgs.lutris ];

  xdg.desktopEntries = {
    star-citizen = lib.mkIf (hostname == "atlas") {
      name = "Star Citizen";
      icon = "stargus";
      exec = "lutris lutris:rungame/star-citizen";
      categories = [ "Game" ];
      type = "Application";
    };
    league-of-legends = lib.mkIf (hostname == "atlas") {
      name = "League of Legends";
      icon = "league-of-legends";
      exec = "lutris lutris:rungame/league-of-legends";
      categories = [ "Game" ];
      type = "Application";
    };
  };

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/games/misterio" = {
      allowOther = true;
      directories = [ "Games/Lutris" ".config/lutris" ".local/share/lutris" ];
    };
  };
}
