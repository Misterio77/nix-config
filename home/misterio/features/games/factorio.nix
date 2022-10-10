{ lib, pkgs, ... }: {
  home = {
    packages = [ pkgs.factorio ];
    persistence = {
      "/persist/games/misterio" = {
        allowOther = true;
        directories = [ ".factorio" ];
      };
    };
  };
}
