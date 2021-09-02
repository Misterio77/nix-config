{ pkgs, ... }:
{
  home.packages = with pkgs.nur.repos.kira-bruneau; [ runescape-launcher ];

  home.persistence."/data/home/misterio".directories = [ "Jagex" ];
}
