{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.shadps4];

  home.persistence = {
    "/persist".directories = [".local/share/shadPS4"];
  };
}
