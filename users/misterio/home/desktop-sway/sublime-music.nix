{ pkgs, lib, persistence, ... }:

{
  home.packages = [ pkgs.sublime-music ];
  home.persistence = lib.mkIf persistence {
    "/data/home/misterio".directories = [ ".config/sublime-music" ];
  };
}
