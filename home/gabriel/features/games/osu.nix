{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.osu-lazer];

  home.persistence = {
    "/persist/${config.home.homeDirectory}".directories = [".local/share/osu"];
  };
}
