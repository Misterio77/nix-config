{ pkgs, lib, features, ... }: {
  home.packages = [ pkgs.lutris ];

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/games/misterio" = {
      allowOther = true;
      directories = [ "Games/Lutris" ".config/lutris" ".local/share/lutris" ];
    };
  };
}
