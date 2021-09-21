{ pkgs, ... }: {
  home.packages = [ pkgs.steam ];
  home.persistence = {
    "/data/games/misterio" = {
      directories = [
        "Games/Steam"
        ".config/Hero_Siege"
        ".config/unity3d/Berserk Games/Tabletop Simulator"
        ".local/share/Tabletop Simulator"
        ".local/share/Steam"
      ];
      files = [ ".steam/steam.token" ".steam/registry.vdf" ];
    };
  };
}
