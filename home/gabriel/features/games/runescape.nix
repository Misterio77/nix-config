{
  pkgs,
  config,
  ...
}: {
  home.packages = [
    pkgs.runelite
  ];

  home.persistence = {
    "/persist/${config.home.homeDirectory}" = {
      allowOther = true;
      directories = [".runelite"];
    };
  };
}
