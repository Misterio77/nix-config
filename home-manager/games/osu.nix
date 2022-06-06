{ pkgs, persistence, lib, ... }: {
  home.packages = [ pkgs.osu-lazer ];

  home.persistence = lib.mkIf persistence {
    "/persist/games/misterio".directories = [ ".local/share/osu" ];
  };
}
