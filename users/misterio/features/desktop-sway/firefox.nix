{ pkgs, lib, features, ... }:

{
  programs.firefox.enable = true;
  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/home/misterio".directories = [ ".mozilla/firefox" ];
  };
}
