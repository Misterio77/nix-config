{ pkgs, ... }:
{
  # Waiting for kira-bruneau
  # home.packages = [ pkgs.nur.kira-bruneau-runescape-launcher ];

  # Temporary soluction
  xdg.desktopEntries = {
    runescape = {
      name = "RuneScape";
      icon = "runescape";
      exec = "nix shell \"github:misterio77/nur-packages?ref=patch-1#runescape-launcher\" -c gamemoderun runescape-launcher";
      categories = [ "Game" ];
      type = "Application";
    };
  };

  home.persistence."/data/home/misterio".directories = [ "Jagex" ];
}
