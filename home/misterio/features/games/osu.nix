{ pkgs, lib, ... }: {
  home.packages = [ pkgs.osu-lazer ];

  home.persistence = {
    "/persist/home/misterio".directories = [ ".local/share/osu" ];
  };
}
