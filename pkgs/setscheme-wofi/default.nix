{ lib, pkgs, stdenv, writeShellScriptBin, setscheme, wofi, zenity }:

with lib;

stdenv.mkDerivation {
  name = "setscheme-wofi";
  version = "1.0";
  src = writeShellScriptBin "setscheme-wofi" ''
    set -o pipefail
    chosen=$(${setscheme}/bin/setscheme -L | ${wofi}/bin/wofi -S dmenu $@) && \
    ${setscheme}/bin/setscheme $chosen --show-trace --verbose 2>&1 | \
    stdbuf -oL -eL awk '/^ / { print int(+$2) ; next } $0 { print "# " $0 }' | \
    ${zenity}/bin/zenity --progress --pulsate --auto-close --auto-kill --title "Change color scheme"
  '';
  dontBuild = true;
  dontConfigure = true;
  installPhase =
    "install -Dm 0755 $src/bin/setscheme-wofi $out/bin/setscheme-wofi";

  meta = {
    description = "A wofi graphical menu for setscheme";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}
