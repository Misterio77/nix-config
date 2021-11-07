{ pkgs, lib, features, ... }: {
  home.packages = [ pkgs.multimc ];

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/games/misterio".directories = [ ".local/share/multimc" ];
  };
}
