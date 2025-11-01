{
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.runelite
    pkgs.hdos
  ];

  home.persistence = {
    "/persist".directories = [".runelite" ".config/hdos"];
  };
}
