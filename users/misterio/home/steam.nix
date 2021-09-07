{ pkgs, ... }: {
  home.packages = [ pkgs.steam ];
  home.persistence = {
    "/data/games/misterio" = {
      directories = [
        "Games/Steam"
        ".config/Hero_Siege"
        ".local/share/Tabletop Simulator"
        ".local/share/Steam"
      ];
      files = [ ".steam/steam.token" ".steam/registry.vdf" ];
    };
  };
}
