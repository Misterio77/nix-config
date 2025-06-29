{
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.runelite
  ];

  home.persistence = {
    "/persist".directories = [".runelite"];
  };
}
