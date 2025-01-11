{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.shadps4];

  home.persistence = {
    "/persist/${config.home.homeDirectory}".directories = [".local/share/shadPS4"];
  };
}
