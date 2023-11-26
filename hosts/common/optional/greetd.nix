{ pkgs, lib, config, ... }:
let
  homeCfgs = config.home-manager.users;
  homeSharePaths = lib.mapAttrsToList (n: v: "${v.home.path}/share") homeCfgs;
  vars = ''XDG_DATA_DIRS="$XDG_DATA_DIRS:${lib.concatStringsSep ":" homeSharePaths}"'';

  # TODO: this should not be coupled to my home config
  # Or at least have some kind of fallback values if it's not present on this machine
  misterioCfg = homeCfgs.misterio;
  mainMonitor = lib.head (lib.filter (x: x.primary) misterioCfg.monitors);
  gtkTheme = misterioCfg.gtk.theme;
  iconTheme = misterioCfg.gtk.iconTheme;
  wallpaper = misterioCfg.wallpaper;

  wlr-randr = lib.getExe pkgs.wlr-randr;
  grep = lib.getExe pkgs.gnugrep;
  cage-kiosk = command: "${lib.getExe pkgs.cage} -s -- ${pkgs.writeShellScript "cage-cmd" ''
    # Turn off every monitor, except the main one
    ${wlr-randr} | ${grep} '^\S' | cut -d ' ' -f1 | \
    ${grep} -v ${mainMonitor.name} | \
    while IFS= read -r output; do
      echo "Turning off $output" >> /tmp/greetd-cage.log
      ${wlr-randr} --output $output --off
    done
    exec ${vars} ${command}
  ''}";
in
{
  users.extraUsers.greeter.packages = [
    gtkTheme.package
    iconTheme.package
  ];

  programs.regreet = {
    enable = true;
    settings = {
      GTK = {
        icon_theme_name = "Papirus";
        theme_name = gtkTheme.name;
      };
      background = {
        path = wallpaper;
        fit = "Cover";
      };
    };
  };
  services.greetd = {
    enable = true;
    settings.default_session.command = cage-kiosk (lib.getExe config.programs.regreet.package);
  };
}
