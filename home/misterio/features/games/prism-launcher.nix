{ pkgs, lib, ... }: {
  home.packages = [ pkgs.prismlauncher-qt5 ];

  home.persistence = {
    "/persist/home/misterio".directories = [ ".local/share/PrismLauncher" ];
  };
}
