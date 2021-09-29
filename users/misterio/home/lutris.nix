{ pkgs, ... }: {
  home.packages = [ pkgs.lutris ];

  xdg.desktopEntries = {
    star-citizen = {
      name = "Star Citizen";
      icon = "stargus";
      exec = "lutris lutris:rungameid/1";
      categories = [ "Game" ];
      type = "Application";
    };
    league-of-legends = {
      name = "League of Legends";
      icon = "league-of-legends";
      exec = "lutris lutris:rungameid/2";
      categories = [ "Game" ];
      type = "Application";
    };
  };

  home.persistence = {
    "/data/games/misterio" = {
      allowOther = true;
      directories = [ "Games/Lutris" ".config/lutris" ".local/share/lutris" ];
    };
  };
}
