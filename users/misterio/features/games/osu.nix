{ pkgs, features, lib, ... }: {
  home.packages = [ pkgs.osu-lazer ];

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/games/misterio".directories = [ ".local/share/osu" ];
  };
}
