{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.prismlauncher];

  home.persistence = {
    "/persist/${config.home.homeDirectory}".directories = [".local/share/PrismLauncher"];
  };
}
