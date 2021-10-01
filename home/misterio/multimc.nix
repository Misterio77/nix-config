{ pkgs, ... }: {
  home.packages = [ pkgs.multimc ];
  home.persistence."/data/games/misterio".directories =
    [ ".local/share/multimc" ];
}
