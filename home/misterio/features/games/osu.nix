{ pkgs, lib, ... }: {
  home.packages = [ pkgs.osu-lazer ];

  home.persistence = {
    "/persist/games/misterio".directories = [ ".local/share/osu" ];
  };
}
