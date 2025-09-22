{
  lib,
  config,
  pkgs,
  ...
}: {
  services.displayManager = {
    enable = true;
    sessionPackages = lib.flatten (lib.mapAttrsToList (_: v: v.home.exportedSessionPackages) config.home-manager.users);
  };
  programs.regreet = {
    enable = true;
    cageArgs = ["-s" "-m" "last"];
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

  environment.persistence = {
    # Persist last user and last selected session
    "/persist".directories = [{
      directory = "/var/lib/regreet";
      user = "greeter";
      group = "greeter";
    }];
  };
}
