{ pkgs, ... }:
{
  home.packages = [ pkgs.multimc ];
  home.persistence."/data/home/misterio".directories = [ ".local/share/multimc" ];
}
