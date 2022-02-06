{ pkgs, lib, persistence, ... }: {
  home.packages = [ pkgs.polymc ];

  home.persistence = lib.mkIf persistence {
    "/persist/games/misterio".directories = [ ".local/share/polymc" ];
  };
}
