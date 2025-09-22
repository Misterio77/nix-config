{
  pkgs,
  lib,
  config,
  ...
}: let
  homeCfgs = config.home-manager.users;
  homeSharePaths = lib.mapAttrsToList (_: v: "${v.home.path}/share") homeCfgs;
  sway-kiosk = command: "${lib.getExe pkgs.sway} --unsupported-gpu --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    xwayland disable
    input "type:touchpad" {
      tap enabled
    }
    exec 'XDG_DATA_DIRS="$XDG_DATA_DIRS:${lib.concatStringsSep ":" homeSharePaths}" GTK_USE_PORTAL=0 ${command}; ${pkgs.sway}/bin/swaymsg exit'
  ''} &>/dev/null";
in {
  users.extraUsers.greeter = {
    # For caching and such
    home = "/tmp/greeter-home";
    createHome = true;
  };

  programs.regreet = {
    enable = true;
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
    settings = {
      default_session = lib.mkDefault {
        command = sway-kiosk (lib.getExe config.programs.regreet.package);
        user = config.users.extraUsers.greeter.name;
      };
    };
  };
}
