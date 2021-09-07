{ pkgs, ... }: {
  home.packages = [ pkgs.osu-lazer ];
  home.persistence."/data/games/misterio".directories = [ ".local/share/osu" ];
}
