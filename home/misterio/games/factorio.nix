{ lib, persistence, pkgs, ... }: {
  home = {
    packages = [ pkgs.factorio ];
    persistence = lib.mkIf persistence {
      "/persist/games/misterio" = {
        allowOther = true;
        directories = [ ".factorio" ];
      };
    };
  };
}
