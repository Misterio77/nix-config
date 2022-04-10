{ pkgs, lib, persistence, ... }: {
  home.packages = [ pkgs.sublime-music ];
  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio".directories = [ ".config/sublime-music" ];
  };
}
