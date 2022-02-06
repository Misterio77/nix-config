{ pkgs, persistence, lib, ... }: {
  home.packages = [ pkgs.osu-lazer ];

  home.persistence = lib.mkIf persistence {
    "/data/games/misterio".directories = [ ".local/share/osu" ];
  };
}
