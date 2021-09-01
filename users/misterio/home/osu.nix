{ pkgs, ... }:
{
  home.packages = [ pkgs.osu-lazer ];
  home.persistence."/data/home/misterio".directories = [ ".local/share/osu" ];
}
