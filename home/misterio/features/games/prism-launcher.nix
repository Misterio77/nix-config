{ pkgs, lib, ... }: {
  home.packages = [ pkgs.prismlauncher ];

  home.persistence = {
    "/persist/home/misterio".directories = [ ".local/share/PrismLauncher" ];
  };
}
