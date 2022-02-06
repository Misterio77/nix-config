{ pkgs, lib, persistence, ... }: {
  home.packages = [ pkgs.polymc ];

  home.persistence = lib.mkIf persistence {
    "/data/games/misterio".directories = [ ".local/share/polymc" ];
  };
}
