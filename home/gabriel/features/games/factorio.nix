{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = [pkgs.factorio];
    persistence = {
      "/persist".directories = [".factorio"];
    };
  };
}
