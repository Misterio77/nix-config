{ lib, stdenv, writeShellScriptBin
, playerctl }:

with lib;

stdenv.mkDerivation {
  name = "preferredplayer";
  version = "1.0";
  src = writeShellScriptBin "preferredplayer" ''
    if [[ -z "$1" ]]; then
        players=$(${playerctl}/bin/playerctl --list-all 2>/dev/null | \
        grep "$(cat $XDG_RUNTIME_DIR/currentplayer 2> /dev/null || echo '.*')") && \
        echo "$players" | head -1
    else
        echo "$1" > $XDG_RUNTIME_DIR/currentplayer
    fi
  '';
  dontBuild = true;
  dontConfigure = true;
  installPhase = "install -Dm 0755 $src/bin/preferredplayer $out/bin/preferredplayer";

  meta = {
    description = "A script for setting a preferred player";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ misterio77 ];
  };
}

