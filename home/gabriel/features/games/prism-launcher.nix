{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.prismlauncher];

  home.persistence = {
    "/persist".directories = [".local/share/PrismLauncher"];
  };
}
