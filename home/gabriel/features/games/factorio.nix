{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = [pkgs.factorio];
    persistence = {
      "/persist/${config.home.homeDirectory}" = {
        allowOther = true;
        directories = [".factorio"];
      };
    };
  };
}
