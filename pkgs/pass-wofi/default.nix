{ lib
, pkgs
, stdenv
, fetchFromGitHub
, makeWrapper
, pass
, jq
, wofi
, libnotify
, wl-clipboard
, findutils
, gnused
, coreutils
}:

with lib;

stdenv.mkDerivation {
  name = "pass-wofi";
  version = "1.0";
  src = ./pass-wofi.sh;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm 0755 $src $out/bin/pass-wofi
    wrapProgram $out/bin/pass-wofi --set PATH \
      "${
        makeBinPath [
          pass
          jq
          wofi
          libnotify
          wl-clipboard
          findutils
          gnused
          coreutils
        ]
      }"
  '';

  meta = {
    description = "A wofi graphical menu for pass";
    license = licenses.mit;
    platforms = platforms.all;
  };
}

