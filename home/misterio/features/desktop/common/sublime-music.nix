{ pkgs, lib, ... }: {
  home.packages = [ pkgs.sublime-music ];
  home.persistence = {
    "/persist/home/misterio".directories = [ ".config/sublime-music" ];
  };
}
