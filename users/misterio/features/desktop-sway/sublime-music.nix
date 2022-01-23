{ pkgs, lib, features, ... }:

{
  home.packages = [ pkgs.sublime-music ];
  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/home/misterio".directories = [ ".config/sublime-music" ];
  };
}
