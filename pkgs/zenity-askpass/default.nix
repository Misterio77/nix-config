{ pkgs, lib, stdenv, writeShellScriptBin, makeWrapper }:

with lib;

stdenv.mkDerivation {
  name = "zenity-askpass";
  version = "1.0";
  src = writeShellScriptBin "zenity-askpass" ''
    zenity --password --timeout 10
  '';
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    install -Dm 0755 $src/bin/zenity-askpass $out/bin/zenity-askpass
    wrapProgram $out/bin/zenity-askpass --set PATH \
      "${makeBinPath [ pkgs.gnome.zenity ]}"
  '';

  meta = {
    description = "A zenity wrapper to act as sudo ask_pass";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}

