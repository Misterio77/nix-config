{ pkgs, lib, ... }: {
  home.packages = [ pkgs.polymc ];

  home.persistence = {
    "/persist/games/misterio".directories = [ ".local/share/polymc" ];
  };
}
