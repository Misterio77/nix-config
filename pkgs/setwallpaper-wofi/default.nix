{ lib, pkgs, stdenv, writeShellScriptBin
, setwallpaper, wofi, zenity }:

with lib;

stdenv.mkDerivation {
  name = "setwallpaper-wofi";
  version = "1.0";
  src = writeShellScriptBin "setwallpaper-wofi" ''
    set -o pipefail
    chosen=$(${setwallpaper}/bin/setwallpaper -L | ${wofi}/bin/wofi -S dmenu $@) && \
    ${setwallpaper}/bin/setwallpaper $chosen --show-trace --verbose 2>&1 | \
    stdbuf -oL -eL awk '/^ / { print int(+$2) ; next } $0 { print "# " $0 }' | \
    ${zenity}/bin/zenity --progress --pulsate --auto-close --auto-kill --title "Change wallpaper"
  '';
  dontBuild = true;
  dontConfigure = true;
  installPhase = "install -Dm 0755 $src/bin/setwallpaper-wofi $out/bin/setwallpaper-wofi";

  meta = {
    description = "A wofi graphical menu for setwallpaper";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}
