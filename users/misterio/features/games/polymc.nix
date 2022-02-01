{ pkgs, lib, features, ... }: {
  home.packages = [ pkgs.polymc ];

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/games/misterio".directories = [ ".local/share/polymc" ];
  };
}
