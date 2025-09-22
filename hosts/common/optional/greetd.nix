{
  lib,
  config,
  pkgs,
  ...
}: let
  sessionPackages = lib.mapAttrsToList (_: v: v.home.exportedSessionPackages) config.home-manager.users;
in {
  programs.regreet = {
    enable = true;
    cageArgs = ["-s" "-m" "last"];
    cageEnv.XDG_DATA_DIRS = lib.map (v: "${v}/share") (lib.flatten sessionPackages);
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };
    font = {
      name = "Fira Sans";
      package = pkgs.fira;
      size = 12;
    };
    cursorTheme = {
      package = pkgs.apple-cursor;
      name = "macOS";
    };
  };

  services.greetd = {
    enable = true;
  };
}
