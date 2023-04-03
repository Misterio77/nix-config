{ lib, pkgs, ... }: {
  home = {
    packages = [ pkgs.factorio ];
    persistence = {
      "/persist/home/misterio" = {
        allowOther = true;
        directories = [ ".factorio" ];
      };
    };
  };
}
