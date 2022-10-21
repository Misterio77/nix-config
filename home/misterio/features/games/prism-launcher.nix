{ pkgs, lib, ... }: {
  home.packages = [ pkgs.prismlauncher ];

  home.persistence = {
    # TODO: Change?
    "/persist/games/misterio".directories = [ ".local/share/polymc" ];
  };
}
